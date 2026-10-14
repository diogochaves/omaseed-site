// www.omaseed.app is attached to the Pages project only to send people to omaseed.app: a permanent
// redirect, path and query kept. Everything else passes through. dist/_routes.json (written by
// build.mjs) keeps /media/* from running this at all. Copied from omabox-site.
export const onRequest = ({ request, next }) => {
  const url = new URL(request.url);
  if (url.hostname !== "www.omaseed.app") return next();
  url.hostname = "omaseed.app";
  return Response.redirect(url.toString(), 301);
};
