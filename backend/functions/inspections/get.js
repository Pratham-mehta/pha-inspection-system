const { getItem, query, INSPECTIONS_TABLE } = require('../../lib/dynamodb');

/**
 * Lambda handler to get inspection details
 */
exports.handler = async (event) => {
  try {
    const { soNumber } = event.pathParameters;

    if (!soNumber) {
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({ error: 'SO Number is required' }),
      };
    }

    // Get main inspection record
    const inspection = await getItem(INSPECTIONS_TABLE, {
      PK: `INSPECTION#${soNumber}`,
      SK: 'METADATA',
    });

    if (!inspection) {
      return {
        statusCode: 404,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({ error: 'Inspection not found' }),
      };
    }

    // Query all related data (responses, images, etc.)
    const relatedItems = await query(INSPECTIONS_TABLE, {
      KeyConditionExpression: 'PK = :pk',
      ExpressionAttributeValues: {
        ':pk': `INSPECTION#${soNumber}`,
      },
    });

    // Organize data
    const responses = relatedItems.filter(item => item.SK.startsWith('RESPONSE#'));
    const pmiResponses = relatedItems.filter(item => item.SK.startsWith('PMI_RESPONSE#'));
    const images = relatedItems.filter(item => item.SK.startsWith('IMAGE#'));
    const signature = relatedItems.find(item => item.SK === 'SIGNATURE');
    const circumstances = relatedItems.filter(item => item.SK.startsWith('CIRCUMSTANCE#'));

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        inspection,
        responses,
        pmiResponses,
        images,
        signature,
        circumstances,
      }),
    };
  } catch (error) {
    console.error('Get inspection error:', error);

    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        error: 'Failed to get inspection',
        message: error.message,
      }),
    };
  }
};
