import React, { useEffect, useState } from "react";

const classes = [
    ["math1", []],
    ["cs1", []],
    ["lit1", []],
    ["pol1", []],
    ["sci1", []],
    ["lang1", []],
    ["art1", []],
    ["des1", []],
    ["math2", ["math1"]],
];

const data = require('./prereqs.json');

function Walkthrough() {
    const [choices, setChoices] = useState([]);
    const [choosing, setChoosing] = useState([]);
    const [updater, setUpdater] = useState([]);
    const [semesters, setSemesters] = useState([]);
    const [takenClasses, setTaken] = useState([]);
    const choiceClear = [];


    console.log(data.CS1100);

    function checkOffer(testClass) {
        if (takenClasses.includes(testClass[0])) {
            return false;
        }

        for (let i = 0; i < testClass[1].length; i++) {
            console.log(testClass[1][i]);
            if (!takenClasses.includes(testClass[1][i])) {
                return false;
            }
        }



        return true;
    }

    function getChoices() {
        const choiceGet = [];
        for (let i = 0; i < classes.length; i++) {
            if (checkOffer(classes[i])) {
                choiceGet.push(classes[i][0]);
            }
        }
        setChoices(choiceGet);
    }

    function clearChoices() {
        setChoices(choiceClear);
        setChoosing(choiceClear);
        setSemesters(choiceClear);
        setTaken(choiceClear);
        window.location.reload();
    }

    function classSelector(text) {
        let chosen = choosing;
        if (!choosing.includes(text)) {
            chosen.push(text);
            setChoosing(chosen);

            for (let i = 0; i < choices.length; i++) {
                if (choices[i] === text) {
                    choices.splice(i, 1);
                }
            }

            setUpdater(choiceClear);
        }        
    }


    function saveSemester() {
        let newYear = [];
        let oldYear = semesters;
        let taken = takenClasses;
        newYear.push(choosing);
        for (let i = 0; i < oldYear.length; i++) {
            newYear.push(oldYear[i]);
        }

        setSemesters(newYear);

        for (let i = 0; i < choosing.length; i++) {
            taken.push(choosing[i]);
        }
        setChoosing(choiceClear);
        setChoices(choiceClear);
        getChoices();
    }

    return (
        <>
            <div class="walkthrough-sections">

                <div class="walkthrough-section1">
                    <div class="walkthrough-menu">
                        <input type="button" class="walkthrough-buttons" onClick={getChoices} value="Start Walkthrough" />
                        <input type="button" class="walkthrough-buttons" onClick={saveSemester} value="Save Semester" />
                        <input type="button" class="walkthrough-buttons" onClick={clearChoices} value="clear" />
                    </div>
                </div>

                <div class="walkthrough-section2">
                    <div class="walk-through">
                        <div class="choice-grid">
                            {choices.map(choice => (
                                <div key={Math.random()}>
                                    <input type="button" class="classButton" onClick={() => classSelector(choice)} value={choice} />
                                </div>
                            ))}
                        </div>                    
                    </div>
                    <div class="choose-grid">
                        {choosing.map(choose => (
                            <div key={Math.random()}>
                                <input type="button" class="classButton" value={choose} />
                            </div>
                        ))}
                    </div>
                    <div>
                        {semesters.map((year, index) => (
                            <div key={Math.random()} class="semester-grid">
                                <h9>Semester {semesters.length - index}</h9>
                                <div class="semester-classes">
                                    {semesters[index].map(course => (
                                        <div key={Math.random()}>
                                            <input type="button" class="classButton" value={course} />
                                        </div>
                                    ))}
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </>
    );
}

export default Walkthrough;