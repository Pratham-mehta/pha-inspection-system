const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, GetCommand, PutCommand, UpdateCommand, DeleteCommand, QueryCommand, ScanCommand } = require('@aws-sdk/lib-dynamodb');

const client = new DynamoDBClient({ region: process.env.AWS_REGION || 'us-east-1' });
const docClient = DynamoDBDocumentClient.from(client);

const TABLE_PREFIX = process.env.DYNAMODB_TABLE_PREFIX || 'dev-pha';
const INSPECTIONS_TABLE = `${TABLE_PREFIX}-inspections`;

/**
 * Get item from DynamoDB
 */
async function getItem(tableName, key) {
  try {
    const command = new GetCommand({
      TableName: tableName,
      Key: key,
    });

    const response = await docClient.send(command);
    return response.Item;
  } catch (error) {
    console.error('DynamoDB getItem error:', error);
    throw error;
  }
}

/**
 * Put item in DynamoDB
 */
async function putItem(tableName, item) {
  try {
    const command = new PutCommand({
      TableName: tableName,
      Item: item,
    });

    await docClient.send(command);
    return item;
  } catch (error) {
    console.error('DynamoDB putItem error:', error);
    throw error;
  }
}

/**
 * Update item in DynamoDB
 */
async function updateItem(tableName, key, updates) {
  try {
    const updateExpression = [];
    const expressionAttributeNames = {};
    const expressionAttributeValues = {};

    Object.keys(updates).forEach((key, index) => {
      const placeholder = `#attr${index}`;
      const valuePlaceholder = `:val${index}`;
      updateExpression.push(`${placeholder} = ${valuePlaceholder}`);
      expressionAttributeNames[placeholder] = key;
      expressionAttributeValues[valuePlaceholder] = updates[key];
    });

    const command = new UpdateCommand({
      TableName: tableName,
      Key: key,
      UpdateExpression: `SET ${updateExpression.join(', ')}`,
      ExpressionAttributeNames: expressionAttributeNames,
      ExpressionAttributeValues: expressionAttributeValues,
      ReturnValues: 'ALL_NEW',
    });

    const response = await docClient.send(command);
    return response.Attributes;
  } catch (error) {
    console.error('DynamoDB updateItem error:', error);
    throw error;
  }
}

/**
 * Delete item from DynamoDB
 */
async function deleteItem(tableName, key) {
  try {
    const command = new DeleteCommand({
      TableName: tableName,
      Key: key,
    });

    await docClient.send(command);
    return true;
  } catch (error) {
    console.error('DynamoDB deleteItem error:', error);
    throw error;
  }
}

/**
 * Query DynamoDB
 */
async function query(tableName, params) {
  try {
    const command = new QueryCommand({
      TableName: tableName,
      ...params,
    });

    const response = await docClient.send(command);
    return response.Items;
  } catch (error) {
    console.error('DynamoDB query error:', error);
    throw error;
  }
}

/**
 * Scan DynamoDB
 */
async function scan(tableName, params = {}) {
  try {
    const command = new ScanCommand({
      TableName: tableName,
      ...params,
    });

    const response = await docClient.send(command);
    return response.Items;
  } catch (error) {
    console.error('DynamoDB scan error:', error);
    throw error;
  }
}

module.exports = {
  getItem,
  putItem,
  updateItem,
  deleteItem,
  query,
  scan,
  INSPECTIONS_TABLE,
};
