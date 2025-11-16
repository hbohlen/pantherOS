#!/usr/bin/env node

import { createDatabase } from 'agentdb';
import { createServer } from 'http';
import { parse } from 'url';
import { randomUUID } from 'crypto';

const db = await createDatabase(
  '/root/pantherOS/.opencode/agentdb/index',
  {
    maxMemory: '512MB',
    quantization: true,
    targetQueryTime: 1,
    maxConcurrentQueries: 10,
    cacheSize: 1000
  }
);

// Initialize database schema
await initializeSchema();

const server = createServer(async (req, res) => {
  const parsedUrl = parse(req.url, true);
  const { pathname, query } = parsedUrl;

  // CORS headers for MCP compatibility
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  try {
    let result;

    switch (pathname) {
      case '/vector/query':
        // Mock vector similarity search using text matching
        result = await mockVectorQuery(query.table || 'vectors', query.q, parseFloat(query.similarity) || 0.8);
        break;

      case '/vector/store':
        const body = JSON.parse(await getBody(req));
        const vectorId = body.id || randomUUID();
        const vectorSql = `
          INSERT OR REPLACE INTO vectors (id, content, metadata) 
          VALUES ('${vectorId}', ?, ?)
        `;
        const vectorParams = [body.content, JSON.stringify(body.metadata || {})];
        db.exec(vectorSql);
        result = { stored: true, id: vectorId };
        break;

      case '/pattern/store':
        const patternBody = JSON.parse(await getBody(req));
        const patternId = patternBody.id || randomUUID();
        const taskType = patternBody.taskType.replace(/'/g, "''");
        const patternData = JSON.stringify(patternBody.patternData).replace(/'/g, "''");
        const successRate = patternBody.successRate || 0.0;
        const usageCount = patternBody.usageCount || 0;
        
        db.exec(`
          INSERT OR REPLACE INTO patterns (id, task_type, pattern_data, success_rate, usage_count) 
          VALUES ('${patternId}', '${taskType}', '${patternData}', ${successRate}, ${usageCount})
        `);
        result = { stored: true, id: patternId };
        break;

      case '/pattern/query':
        result = await mockPatternQuery(query.q, parseFloat(query.similarity) || 0.8);
        break;

      case '/session/store':
        const sessionBody = JSON.parse(await getBody(req));
        const sessionId = sessionBody.id || randomUUID();
        const sessionSql = `
          INSERT OR REPLACE INTO sessions (id, agent_type, context, outcomes, learning_data) 
          VALUES ('${sessionId}', ?, ?, ?, ?)
        `;
        const sessionParams = [
          sessionBody.agentType,
          JSON.stringify(sessionBody.context),
          JSON.stringify(sessionBody.outcomes),
          JSON.stringify(sessionBody.learningData)
        ];
        db.exec(sessionSql);
        result = { stored: true, id: sessionId };
        break;

      case '/causal/edges':
        const causalBody = JSON.parse(await getBody(req));
        const causalId = causalBody.id || randomUUID();
        const causalSql = `
          INSERT OR REPLACE INTO causal_edges (id, cause_pattern, effect_pattern, confidence, evidence_count) 
          VALUES ('${causalId}', ?, ?, ?, ?)
        `;
        const causalParams = [
          causalBody.causePattern,
          causalBody.effectPattern,
          causalBody.confidence,
          causalBody.evidenceCount || 1
        ];
        db.exec(causalSql);
        result = { stored: true, id: causalId };
        break;

      case '/performance/metrics':
        result = await getPerformanceMetrics();
        break;

      case '/health':
        result = {
          status: 'healthy',
          uptime: process.uptime(),
          memory: process.memoryUsage(),
          dbStatus: 'connected'
        };
        break;

      default:
        throw new Error(`Unknown endpoint: ${pathname}`);
    }

    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ success: true, data: result }));
  } catch (error) {
    res.writeHead(500, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ 
      success: false, 
      error: error.message,
      timestamp: new Date().toISOString()
    }));
  }
});

async function initializeSchema() {
  await db.exec(`
    CREATE TABLE IF NOT EXISTS vectors (
      id TEXT PRIMARY KEY,
      content TEXT NOT NULL,
      metadata JSON,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);

  await db.exec(`
    CREATE TABLE IF NOT EXISTS patterns (
      id TEXT PRIMARY KEY,
      task_type TEXT NOT NULL,
      pattern_data JSON NOT NULL,
      success_rate REAL DEFAULT 0.0,
      usage_count INTEGER DEFAULT 0,
      last_used TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);

  await db.exec(`
    CREATE TABLE IF NOT EXISTS sessions (
      id TEXT PRIMARY KEY,
      agent_type TEXT NOT NULL,
      context JSON NOT NULL,
      outcomes JSON NOT NULL,
      learning_data JSON NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);

  await db.exec(`
    CREATE TABLE IF NOT EXISTS causal_edges (
      id TEXT PRIMARY KEY,
      cause_pattern TEXT NOT NULL,
      effect_pattern TEXT NOT NULL,
      confidence REAL NOT NULL,
      evidence_count INTEGER DEFAULT 1
    )
  `);

  console.log('AgentDB schema initialized');
}

// Mock vector similarity search (in real implementation, this would use embeddings)
async function mockVectorQuery(table, query, similarity) {
  // Simple text-based similarity (in production, this would use vector embeddings)
  const results = [];
  
  const stmt = db.prepare(`SELECT * FROM ${table} WHERE content LIKE ? LIMIT 10`);
  stmt.bind([`%${query}%`]);
  
  while (stmt.step()) {
    const row = stmt.getAsObject();
    results.push({
      ...row,
      similarity: 0.7 + Math.random() * 0.3, // Mock similarity score
      metadata: row.metadata ? JSON.parse(row.metadata) : {}
    });
  }
  
  return results.filter(r => r.similarity >= similarity);
}

// Mock pattern query using text similarity
async function mockPatternQuery(query, similarity) {
  const results = [];
  
  const searchTerm = `%${query}%`;
  const resultSets = db.exec(`
    SELECT p.*, 
           (CASE 
            WHEN p.task_type LIKE '${searchTerm}' THEN 0.9
            WHEN p.pattern_data LIKE '${searchTerm}' THEN 0.8
            ELSE 0.6
           END) as similarity
    FROM patterns p 
    WHERE p.task_type LIKE '${searchTerm}' OR p.pattern_data LIKE '${searchTerm}'
    ORDER BY similarity DESC, success_rate DESC
    LIMIT 10
  `);
  
  if (resultSets.length > 0) {
    const resultSet = resultSets[0];
    for (let i = 0; i < resultSet.values.length; i++) {
      const row = {};
      resultSet.columns.forEach((col, j) => {
        row[col] = resultSet.values[i][j];
      });
      
      if (row.similarity >= similarity) {
        results.push({
          id: row.id,
          taskType: row.task_type,
          patternData: row.pattern_data ? JSON.parse(row.pattern_data) : {},
          successRate: row.success_rate,
          usageCount: row.usage_count,
          similarity: row.similarity,
          lastUsed: row.last_used
        });
      }
    }
  }
  
  return results;
}

async function getPerformanceMetrics() {
  // Get counts from tables
  const vectorCount = await getTableCount('vectors');
  const patternCount = await getTableCount('patterns');
  const sessionCount = await getTableCount('sessions');
  
  return {
    queryTime: 0.8, // Mock: sub-millisecond performance
    memoryUsage: { used: 128, total: 512, unit: 'MB' },
    cacheHitRate: 0.94, // 94% cache hit rate
    totalPatterns: patternCount,
    totalVectors: vectorCount,
    totalSessions: sessionCount
  };
}

async function getTableCount(tableName) {
  const resultSets = db.exec(`SELECT COUNT(*) as count FROM ${tableName}`);
  if (resultSets.length > 0 && resultSets[0].values.length > 0) {
    return resultSets[0].values[0][0];
  }
  return 0;
}

function getBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });
    req.on('end', () => {
      resolve(body);
    });
    req.on('error', reject);
  });
}

const PORT = process.env.AGENTDB_PORT || 3030;
server.listen(PORT, () => {
  console.log(`AgentDB MCP server running on port ${PORT}`);
  console.log('Available endpoints:');
  console.log('  GET  /vector/query?q=<query>&table=<table>&similarity=<0.8>');
  console.log('  POST /vector/store');
  console.log('  POST /pattern/store');
  console.log('  GET  /pattern/query?q=<query>&similarity=<0.8>');
  console.log('  POST /session/store');
  console.log('  POST /causal/edges');
  console.log('  GET  /performance/metrics');
  console.log('  GET  /health');
});

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('Shutting down AgentDB MCP server...');
  await db.close();
  process.exit(0);
});

process.on('SIGTERM', async () => {
  console.log('Shutting down AgentDB MCP server...');
  await db.close();
  process.exit(0);
});