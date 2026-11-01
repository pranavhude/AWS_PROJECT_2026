const http = require("http");

const PORT = Number(process.env.PORT || 80);

const server = http.createServer((req, res) => {
  if (req.url === "/health" || req.url === "/health/") {
    res.writeHead(200, { "Content-Type": "application/json" });
    return res.end(JSON.stringify({ status: "healthy" }));
  }

  res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
  res.end(`<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>AWSPro ECS Test App</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 0; background: #f3f6fb; color: #172033; }
    main { max-width: 720px; margin: 10vh auto; padding: 32px; background: white;
           border-radius: 14px; box-shadow: 0 8px 28px rgba(0,0,0,.08); }
    h1 { color: #1769aa; } code { background: #eef3f8; padding: 3px 6px; border-radius: 4px; }
  </style>
</head>
<body>
  <main>
    <h1>AWSPro ECS deployment successful!</h1>
    <p>Your test application is running inside an ECS container on EC2.</p>
    <p>Container port: <code>${PORT}</code></p>
    <p>Health endpoint: <code>/health</code></p>
  </main>
</body>
</html>`);
});

server.listen(PORT, "0.0.0.0", () => {
  console.log(`Test app listening on port ${PORT}`);
});

process.on("SIGTERM", () => {
  console.log("SIGTERM received; shutting down gracefully.");
  server.close(() => process.exit(0));
});
