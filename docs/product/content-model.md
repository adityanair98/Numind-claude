# Content Model

## Module
A group of lessons and practice sets.

Fields:
- id
- title
- subtitle
- icon
- color
- lessonIds

## Lesson
A short learning unit.

Fields:
- id
- moduleId
- title
- concept
- example
- shortcut
- quizTemplateIds

## QuizTemplate
Defines generated questions.

Fields:
- id
- moduleId
- promptTemplate
- variableRules
- answerFormula
- explanationTemplate
- difficulty