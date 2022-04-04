import React, { useEffect, useState } from "react";

const classes = [
    ["math1", null],
    ["cs1", null],
    ["lit1", null],
    ["pol1", null],
    ["sci1", null],
    ["lang1", null],
    ["art1", null],
    ["des1", null],
    ["math2", ["math1"]],
];

function Walkthrough() {
    const [choices, setChoices] = useState([]);
    const [choosing, setChoosing] = useState([]);
    let takenClasses = [];
    const choiceClear = [];

    function checkOffer(testClass) {
        if (takenClasses.includes(testClass[0])) {
            return false;
        }

        for (let val in testClass[1]) {
            if (!takenClasses.includes(val)) {
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
    }

    function classSelector(text) {
        let chosen = choosing;
        chosen.push(text);
        setChoosing(chosen);
        console.log(choosing);
    }

    return (
        <>
            <div>
                <div id="head-bar">
                    <h7>Georgia Tech</h7>
                </div>

                <div id="page-title">
                    <h8>Advising Pathways</h8>
                </div>

                <input type="button" onClick={getChoices} value="Start Walkthrough" />
                <input type="button" onClick={clearChoices} value="clear" />

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
            </div>
        </>
    );
}

export default Walkthrough;