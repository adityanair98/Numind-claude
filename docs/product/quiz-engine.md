# Quiz Engine

## Principle
Questions should be generated from templates, not hardcoded one by one.

## Template Requirements
Each template should define:
- id
- module
- difficulty
- prompt template
- variables
- correct answer formula
- answer format
- distractor strategy
- explanation template

## Example
{
  "id": "tip_percent_basic",
  "module": "tips",
  "difficulty": 1,
  "prompt": "What is {{tipPercent}}% of ${{billAmount}}?",
  "variables": {
    "tipPercent": [15, 18, 20],
    "billAmount": [32, 45, 60, 75]
  },
  "answerType": "currency",
  "explanation": "Find 10%, then build up from there."
}

## Question Types
V1: multiple choice only.

Deferred (post-V1):
- numeric input
- comparison
- estimate range

## V1 Question Modules
- tips
- bill split
- discounts
- percentages