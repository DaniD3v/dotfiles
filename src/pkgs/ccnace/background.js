browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
  fetch(request.answersURL)
    .then((response) => response.text())
    .then((text) => {
      sendResponse({ html: text });
    })
    .catch((error) => {
      sendResponse({ error: error.toString() });
    });
  return true; // Required to use async sendResponse
});
