import { readFile } from "fs/promises"
import { resolve } from "path"

/**
 * Configuration for environment variable loading
 */
export interface EnvLoaderConfig {
  /** Custom paths to search for .env files (relative to current working directory) */
  searchPaths?: string[]
  /** Whether to override existing environment variables */
  override?: boolean
}

/**
 * Default search paths for .env files
 */
const DEFAULT_ENV_PATHS = [
  './.env',
  '../.env', 
  '../../.env',
  '../plugin/.env',
  '../../../.env'
]

/**
 * Load environment variables from .env files
 * Searches multiple common locations for .env files and loads them into process.env
 */
export async function loadEnvVariables(config: EnvLoaderConfig = {}): Promise<Record<string, string>> {
  const { 
    searchPaths = DEFAULT_ENV_PATHS, 
    override = false 
  } = config
  
  const loadedVars: Record<string, string> = {}
  
  for (const envPath of searchPaths) {
    try {
      const fullPath = resolve(envPath)
      const content = await readFile(fullPath, 'utf8')
      
      const lines = content.split('\n')
      for (const line of lines) {
        const trimmed = line.trim()
        if (trimmed && !trimmed.startsWith('#') && trimmed.includes('=')) {
          const [key, ...valueParts] = trimmed.split('=')
          const value = valueParts.join('=').trim()
          const cleanValue = value.replace(/^["']|["']$/g, '')
          
          if (key && cleanValue && (override || !process.env[key])) {
            process.env[key] = cleanValue
            loadedVars[key] = cleanValue
          }
        }
      }
    } catch {
      // File doesn't exist or can't be read, continue to next
    }
  }
  
  return loadedVars
}

/**
 * Get a specific environment variable with automatic .env file loading
 */
export async function getEnvVariable(varName: string, config: EnvLoaderConfig = {}): Promise<string | null> {
  let value = process.env[varName]
  
  if (!value) {
    const loadedVars = await loadEnvVariables(config)
    value = loadedVars[varName] || process.env[varName]
  }
  
  return value || null
}

/**
 * Get a required environment variable with automatic .env file loading
 */
export async function getRequiredEnvVariable(varName: string, config: EnvLoaderConfig = {}): Promise<string> {
  const value = await getEnvVariable(varName, config)
  
  if (!value) {
    const searchPaths = config.searchPaths || DEFAULT_ENV_PATHS
    throw new Error(`${varName} not found. Please set it in your environment or .env file.`)
  }
  
  return value
}

/**
 * Load multiple required environment variables at once
 */
export async function getRequiredEnvVariables(varNames: string[], config: EnvLoaderConfig = {}): Promise<Record<string, string>> {
  const result: Record<string, string> = {}
  
  await loadEnvVariables(config)
  
  for (const varName of varNames) {
    const value = process.env[varName]
    if (!value) {
      throw new Error(`Required environment variable ${varName} not found.`)
    }
    result[varName] = value
  }
  
  return result
}

/**
 * Utility function specifically for API keys
 */
export async function getApiKey(apiKeyName: string, config: EnvLoaderConfig = {}): Promise<string> {
  return getRequiredEnvVariable(apiKeyName, config)
}
