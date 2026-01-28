const { invokeClaude, buildInspectionSystemPrompt } = require('../../lib/bedrock');

/**
 * Lambda handler for chatbot queries
 */
exports.handler = async (event) => {
  try {
    const body = JSON.parse(event.body);
    const { query, inspectionContext, conversationHistory = [] } = body;

    if (!query) {
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({ error: 'Query is required' }),
      };
    }

    // Build system prompt with inspection context
    const systemPrompt = buildInspectionSystemPrompt(inspectionContext);

    // Build messages array for Claude
    const messages = [
      ...conversationHistory.map(msg => ({
        role: msg.role,
        content: msg.content,
      })),
      {
        role: 'user',
        content: query,
      },
    ];

    // Invoke Claude
    const response = await invokeClaude(systemPrompt, messages, {
      maxTokens: 1000,
      temperature: 0.7,
    });

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        message: response.message,
        usage: response.usage,
      }),
    };
  } catch (error) {
    console.error('Chatbot query error:', error);

    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        error: 'Failed to process chatbot query',
        message: error.message
      }),
    };
  }
};
