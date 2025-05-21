# ccnace

A tool to achieve 100 % on any CCNA exam.

## Setup
This is a firefox extension. In order to use it, first download and unzip the add-on.
> Note: In the future, it may also be available on addons.mozilla.org.

Open any firefox-based browser and visit `about:debugging#/runtime/this-firefox`. Then scroll down until you see `Temporary Extensions`. Press the `Load Temporary Add-on...` button and select any file inside the unzipped directory.

Now you are good to go!

## Usage

### Set URL
Use `p` to set the URL of the solutions site.

> For CCNA 2: https://itexamanswers.net/ccna-2-v7-0-final-exam-answers-full-switching-routing-and-wireless-essentials.html

Please regard that the bar on the left and the actual questions are two seperate windows. If you set up the answer data in the question window using `p`. You must also execute `a` in that same window (have your cursor there and click on it).

### Copying the question
CCNA prohibits copy-pasting on their exams.
To circumvent this you can use the "Allow Right-Click" Extension.

### Fetch Solutions
After copying a question to your clipboard, you can press `a` to fetch the answer to the question. This only works for questions that are NOT drag-and-drop.
> Excluded: 10, 13, 16, 43, 93, 97, 108, 116

### Display Answers
In order to actually view the solution, you must keep the `l` key pressed. The list of solutions for the current question will appear on the bottom right.

## Caveats
The format of some questions may be problematic. When coyping, make sure to:
- Only copy the question text. (not the number in front of it)
- For longer questions with code blocks, only copy the last paragraph with the final question.
- Make sure not to copy trailing whitespaces.

Some websites disallow copying of questions, thus [additional add-ons may be required](https://addons.mozilla.org/en-US/firefox/addon/re-enable-right-click/).
