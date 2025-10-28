const QUESTION_REGEX = /^(?:[0-9]+\.\s*)?([\s\S]*)$/m;
const SKIP_REGEX = [/^Case\s+\d+.*:/i];
let answerData;
const ANSWER_SELECTOR =
  ".correct_answer, [style*='color: #ff0000'], [style*='color: red']";
const URL_KEY = "CCNA_EXAMS_URL";

const answerElement = document.createElement("ul");
answerElement.id = "answer";
answerElement.style.visibility = "hidden";
answerElement.style.zIndex = "999999";
answerElement.style.position = "fixed";
answerElement.style.bottom = "100px";
answerElement.style.right = "20%";
answerElement.style.opacity = "0.7";
answerElement.style.color = "#0000001A";

document.body.appendChild(answerElement);
window.answer = answerElement;

function updateAnswers(newAnswers) {
  // clear current answers
  window.answer.innerHTML = "";

  // update answers
  for (let a of newAnswers) {
    const li = document.createElement("li");
    li.textContent = a;
    window.answer.appendChild(li);
  }
}

window.addEventListener("keydown", async (event) => {
  switch (event.key) {
    case "p":
      const storedURL = localStorage.getItem(URL_KEY);
      const newAnswersURL = prompt(
        "Please input the answer url (itexamanswers.net)",
        storedURL ?? "",
      );
      if (!newAnswersURL) {
        return;
      }
      localStorage.setItem(URL_KEY, newAnswersURL);
      answerData = await fetchAnswers(newAnswersURL);
      break;
    case "a":
      // fetch using stored URL
      if (!answerData) {
        const storedURL = localStorage.getItem(URL_KEY);
        if (!storedURL) {
          window.answer.innerText = "No URL selected. Use `p` in same window.";
          return;
        }

        answerData = await fetchAnswers(storedURL);
      }

      answerQuestion(answerData);
      break;
    case "l":
      window.answer.style.visibility = "visible";
      break;
  }
});

window.addEventListener("keyup", (event) => {
  if (event.key === "l") {
    window.answer.style.visibility = "hidden";
  }
});

function fetchAnswers(url) {
  return browser.runtime.sendMessage({ answersURL: url }).then(
    (response) => {
      if (response.error) {
        return Promise.reject(response.error);
      } else {
        return new Promise((resolve) => parseAnswers(response.html, resolve));
      }
    },
    (error) => {
      return Promise.reject(error);
    },
  );
}

/**
 *
 * @param {string} html
 * @param {(value: Map<string, string[]> | PromiseLike<Map<string, string[]>>) => void} resolve
 */
function parseAnswers(html, resolve) {
  const allAnswersElement = getAllAnswersElement(html);

  let results = parse(allAnswersElement);

  resolve(results);
}

/**
 * @param {GMXMLHttpRequestResponse} response
 * @returns {Element}
 */
function getAllAnswersElement(response) {
  const parser = new DOMParser();
  const virtualDOM = parser.parseFromString(response, "text/html");
  let answersElement = virtualDOM.querySelector(".pf-content");
  if (!answersElement) {
    answersElement = virtualDOM.querySelector(".thecontent");
  }
  return answersElement;
}

function parse(allAnswersElement) {
  const correctAnswers = allAnswersElement.querySelectorAll(ANSWER_SELECTOR);

  // <question> : [<answers>]
  const results = new Map();
  correctAnswers.forEach((ans) => {
    let questionElement = findPreviousStrong(ans, allAnswersElement);
    let question = parseQuestion(questionElement);

    let answerText = ans.textContent.trim();
    if (answerText.endsWith("*")) {
      answerText = answerText.substring(0, answerText.length - 1);
    }
    const existingAnswers = results.get(question);
    if (existingAnswers) {
      if (!existingAnswers.includes(answerText)) {
        existingAnswers.push(answerText);
      }
    } else {
      results.set(question, [answerText]);
    }
  });

  return results;
}
/**
 * @param {Element} questionElement
 * @returns {String}
 */
function parseQuestion(questionElement) {
  const textContent = questionElement.textContent.trim().replace(/<br>/g, "\n");
  const matches = textContent.match(QUESTION_REGEX);
  return matches !== null ? matches[1] : null;
}

function findPreviousStrong(target, allAnswersElement) {
  const walker = allAnswersElement.ownerDocument.createTreeWalker(
    allAnswersElement,
    NodeFilter.SHOW_ELEMENT,
  );

  let lastStrong = null;
  let currentNode;

  // Walk forward to the target and keep track of all <strong> tags along the way
  while ((currentNode = walker.nextNode())) {
    if (currentNode === target) {
      break;
    }
    if (
      (currentNode.tagName === "STRONG" || currentNode.tagName === "B") &&
      !SKIP_REGEX.some((regex) => regex.test(currentNode.textContent.trim())) &&
      !currentNode.querySelector(ANSWER_SELECTOR) &&
      !currentNode.matches(ANSWER_SELECTOR) &&
      !currentNode.parentNode.matches(ANSWER_SELECTOR)
    ) {
      lastStrong = currentNode;
    }
  }
  return lastStrong;
}

async function readClipboard() {
  try {
    const text = await navigator.clipboard.readText();
    return text;
  } catch (err) {
    console.error("Failed to read clipboard: ", err);
  }
  return null;
}

// answer .js
async function answerQuestion(answerData) {
  const questionText = await readClipboard();
  if (!questionText) {
    return;
  }

  const correctAnswers = findAnswers(answerData, questionText);
  if (
    correctAnswers === null ||
    correctAnswers === undefined ||
    correctAnswers.length === 0
  ) {
    window.answer.innerHTML = "no answers found";
    return;
  }
  updateAnswers(correctAnswers);
}

function findAnswers(answerData, questionText) {
  if (answerData === null) {
    return [];
  }

  let answers = answerData.get(questionText.trim());
  return answers;
}
