Deno.test("Edge Function test harness provides the standard request APIs", () => {
  const request = new Request("http://localhost/functions/v1/harness");
  const pathname = new URL(request.url).pathname;

  if (pathname !== "/functions/v1/harness") {
    throw new Error(`Unexpected request pathname: ${pathname}`);
  }
});
