const { BedrockRuntimeClient, InvokeModelCommand } = require('@aws-sdk/client-bedrock-runtime');

const bedrockClient = new BedrockRuntimeClient({ region: process.env.AWS_REGION || 'us-east-1' });

const MODEL_ID = 'anthropic.claude-3-5-sonnet-20241022-v2:0';

/**
 * Invoke Claude model via Bedrock
 */
async function invokeClaude(systemPrompt, messages, options = {}) {
  const {
    maxTokens = 1000,
    temperature = 0.7,
  } = options;

  const payload = {
    anthropic_version: 'bedrock-2023-05-31',
    max_tokens: maxTokens,
    system: systemPrompt,
    messages: messages,
    temperature: temperature,
  };

  try {
    const command = new InvokeModelCommand({
      modelId: MODEL_ID,
      contentType: 'application/json',
      accept: 'application/json',
      body: JSON.stringify(payload),
    });

    const response = await bedrockClient.send(command);
    const responseBody = JSON.parse(new TextDecoder().decode(response.body));

    return {
      message: responseBody.content[0].text,
      usage: responseBody.usage,
    };
  } catch (error) {
    console.error('Bedrock invocation error:', error);
    throw new Error('Failed to get response from AI assistant');
  }
}

/**
 * Build system prompt for PHA inspections
 */
function buildInspectionSystemPrompt(inspectionContext) {
  return `You are an AI assistant for PHA (Philadelphia Housing Authority) inspectors.
You help with inspection procedures, NSPIRE standards, deficiency codes, material requirements,
and HUD regulations. Provide clear, concise, and accurate guidance.

Current Inspection Context:
${inspectionContext ? JSON.stringify(inspectionContext, null, 2) : 'No active inspection'}

Guidelines:
- Provide specific, actionable advice
- Reference NSPIRE standards when applicable
- Include relevant service codes and activity codes when known
- Be concise but thorough
- If you're unsure, say so rather than guessing`;
}

module.exports = {
  invokeClaude,
  buildInspectionSystemPrompt,
};
