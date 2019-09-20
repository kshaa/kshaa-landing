export default async () => {
  const statusResponse = await fetch('/api/status');
  const statusJson = await statusResponse.json();

  return statusJson.isAuthenticated;
};
