import { useCallback } from "react";
import "survey-react/modern.min.css";
import { Survey, StylesManager, Model } from "survey-react";
import { useNavigate } from "react-router-dom";
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
        "name": "1",
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
        "name": "2",
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
        "name": "3",
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
        "name": "4",
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
        "name": "5",
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
        "name": "6",
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
        "name": "7",
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
        "name": "8",
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

const threads = ['Devices', 'Information Internetworks', 'Intelligence', 'Media', 'Modeling & Simulation', 'People', 'Systems & Architecture', 'Theory']

function ThreadSurvey() {
  
  const survey = new Model(surveyJson);

  survey.focusFirstQuestionAutomatic = false;

  const nav = useNavigate();

  const backtohome = () =>{ 
      let path = `/home`; 
      nav(path);
  }

  const alertResults = useCallback((sender) => {
    // const results = JSON.stringify(sender.data);

    let scores = []
    for (let i = 0; i < 8; i++) {
      scores.push(sender.data[i+1]);
    }

    let highest = Math.max(scores);
    console.log(scores)
    
    let results = "We recommend the folowing threads: "
    for (let i = 0; i < 8; i++) {
     if (scores[i] == highest) {
       results = results + threads[i] + " "
     }
    }

    alert(results);

  }, []);

  survey.onComplete.add(alertResults);
  survey.onComplete.add(backtohome)
    return (
        <>
            <Survey model={survey} />
        </>);
  
}

export default ThreadSurvey;
