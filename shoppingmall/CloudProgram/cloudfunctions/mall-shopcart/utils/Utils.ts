const { ClientIdCredential } = require('@agconnect/common-server/dist/credential-service/clientid-credential');

export const getCredential = (context, logger) => {
  try {
    const credential = JSON.parse(context.env.PROJECT_CREDENTIAL);
    if (credential.type === 'team_client_id') {
      return new ClientIdCredential('', '', credential.developer_id, credential.type, credential.client_id, credential.client_secret, credential.configuration_version);
    } else if (credential.type === 'project_client_id') {
      return new ClientIdCredential(credential.project_id, credential.region, credential.developer_id, credential.type, credential.client_id, credential.client_secret, credential.configuration_version);
    }
  } catch {
    logger.error('get project credential failed');
  }
}
