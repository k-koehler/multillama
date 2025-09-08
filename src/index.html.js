export default function indexHtml(
  urls,
) {
  return `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>multillama</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    h1 { color: #333; }
    .model-list { margin-top: 20px; }
    .model { border: 1px solid #ccc; padding: 10px; margin-bottom: 10px; }
    .model h2 { margin: 0 0 10px 0; }
    .model p { margin: 5px 0; }
    .model a { color: #0066cc; text-decoration: none; }
    .model a:hover { text-decoration: underline; }
  </style>
</head>
<body>
  <h1>multillama Model List</h1>
  <div class="model-list">
    ${urls.map(({ url, key }, index) => `
      <div class="model"> 
        <h2>Source ${index + 1}</h2>
        <p><strong>URL:</strong> <a href="${url}" target="_blank" rel="noopener noreferrer">${url}</a></p>
        <p><strong>Key:</strong> ${key ? 'Provided' : 'None'}</p>
      </div>
    `).join('')}
  </div>
</body>
</html>`
}