import { useCallback } from "react";
import "survey-react/modern.min.css";
import { Survey, StylesManager, Model } from "survey-react";

StylesManager.applyTheme("modern");

const surveyJson = {
    "title": "Threads",
    "description": "Choose questions if you dare",
    "logoPosition": "right",
    "pages": [
     {
      "name": "page1",
      "elements": [
       {
        "type": "rating",
        "name": "question1",
        "title": "Do you like using using a variety of technology to solve problems?",
        "rateValues": [
         1,
         2,
         3,
         4,
         5
        ],
        "minRateDescription": "Not really",
        "maxRateDescription": "Love that"
       },
       {
        "type": "rating",
        "name": "question2",
        "title": "Would you someday want to be able to make network based applications?",
        "rateValues": [
         1,
         2,
         3,
         4,
         5
        ],
        "minRateDescription": "Not really",
        "maxRateDescription": "Love that"
       },
       {
        "type": "rating",
        "name": "question3",
        "title": "Does artificial intelligence and computer autonomous systems sound good for the world? ",
        "rateValues": [
         1,
         2,
         3,
         4,
         5
        ],
        "minRateDescription": "Not really",
        "maxRateDescription": "Love that"
       },
       {
        "type": "rating",
        "name": "question4",
        "title": "Would you want to use Computer Science in the wide variety of media platforms? ",
        "rateValues": [
         1,
         2,
         3,
         4,
         5
        ],
        "minRateDescription": "Not really",
        "maxRateDescription": "Love that"
       }
      ]
     },
     {
      "name": "page2",
      "elements": [
       {
        "type": "rating",
        "name": "question6",
        "title": "Do you like to model your situations around you?",
        "rateValues": [
         1,
         2,
         3,
         4,
         5
        ],
        "minRateDescription": "Not really",
        "maxRateDescription": "Love that"
       },
       {
        "type": "rating",
        "name": "question7",
        "title": "Do you want to focus on the people who would use your technology?",
        "rateValues": [
         1,
         2,
         3,
         4,
         5
        ],
        "minRateDescription": "Not really",
        "maxRateDescription": "Love that"
       },
       {
        "type": "rating",
        "name": "question8",
        "title": "Are you interested in the hardware aspects of computers and learning software to interact with this hardware? ",
        "rateValues": [
         1,
         2,
         3,
         4,
         5
        ],
        "minRateDescription": "Not really",
        "maxRateDescription": "Love that"
       },
       {
        "type": "rating",
        "name": "question9",
        "title": "Would you like to develop advanced mathematical skills to understand and develop complex algorithms?",
        "rateValues": [
         1,
         2,
         3,
         4,
         5
        ],
        "minRateDescription": "Not really",
        "maxRateDescription": "Love that"
       }
      ]
     }
    ]
};

function ThreadSurvey() {
  const survey = new Model(surveyJson);
  survey.focusFirstQuestionAutomatic = false;

  const alertResults = useCallback((sender) => {
    const results = JSON.stringify(sender.data);
    alert(results);
  }, []);

  survey.onComplete.add(alertResults);
  return <Survey model={survey} />
//   return (
//   <>
//   <head>
//       <title>Home</title>
//   </head>
//   <body>
//       <div id="head-bar">
//           <h7>Georgia Tech</h7>
//       </div>

//       <div id="page-title">
//           <h8>Advising Pathways</h8>
//       </div>

//       <div id="surveyContainer">
//           <Survey model={survey} />
//       </div>
//   </body>
//   </>
//   )
}

export default ThreadSurvey;
