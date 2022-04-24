import React, { useEffect, useState } from "react";

const classesOld = [
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

const prereq = require('./prereqs.json');
const threads = require('./threads.json');

function Walkthrough() {
    const [classes, setClasses] = useState([]);
    const [choices, setChoices] = useState([]);
    const [choosing, setChoosing] = useState([]);
    const [updater, setUpdater] = useState([]);
    const [semesters, setSemesters] = useState([]);
    const [takenClasses, setTaken] = useState([]);
    const choiceClear = [];

    /*for (let ent in threads) {
        if (ent == "core") {
            console.log(threads[ent]);
        }
    }*/

    function makeClasses() {
        const classGet = [];
        let checker = true;
        let t1 = getThread("thread1");
        let t2 = getThread("thread2");
        for (let ent in threads) {
            if (ent == t1) {
                for (let i = 1; i < threads[ent][0].length; i++) {
                    for (let val in prereq) {
                        if (val == threads[ent][0][i]) {
                            classGet.push([threads[ent][0][i], prereq[val][0]]);
                        }
                    }
                }
            }
        }

        if (t1 != t2) {
            for (let ent in threads) {
                if (ent == t2) {
                    for (let i = 1; i < threads[ent][0].length; i++) {
                        for (let k = 0; k < classGet.length; k++) {
                            if (classGet[k][0] == threads[ent][0][i]) {
                                checker = false;
                            }                            
                        }
                        if (checker) {
                            for (let val in prereq) {
                                if (val == threads[ent][0][i]) {
                                    classGet.push([threads[ent][0][i], prereq[val][0]]);
                                }
                            }
                        }
                        checker = true;
                    }
                }
            }
        }

        for (let ent in threads) {
            if (ent == "core") {
                for (let i = 1; i < threads[ent][0].length; i++) {
                    for (let k = 0; k < classGet.length; k++) {
                        if (classGet[k][0] == threads[ent][0][i]) {
                            checker = false;
                        }
                    }
                    if (checker) {
                        for (let val in prereq) {
                            if (val == threads[ent][0][i]) {
                                classGet.push([threads[ent][0][i], prereq[val][0]]);
                                checker = false;
                            }
                        }
                    }

                    if (checker) {
                        classGet.push([threads[ent][0][i], []]);
                    }
                    checker = true;
                }
            }
        }
        setClasses(classGet);
    }

    function checkOffer(testClass) {
        if (takenClasses.includes(testClass[0])) {
            return false;
        }

        for (let i = 0; i < testClass[1].length; i++) {
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
        console.log(classes);
        setChoices(choiceGet);
    }

    function clearChoices() {
        setChoices(choiceClear);
        setChoosing(choiceClear);
        setSemesters(choiceClear);
        setTaken(choiceClear);
        setClasses(choiceClear);
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

    function getThread(thread) {
        var select1 = document.getElementById(thread);
        var threadChoice = select1.options[select1.selectedIndex].value;
        return threadChoice;
    }

    return (
        <>
            <div class="walkthrough-sections">

                <div class="walkthrough-section1">
                    <div class="walkthrough-menu">

                        <label htmlFor="thread1">Thread 1:</label>
                        <select class="walkthrough-buttons" name="thread1" id="thread1">
                            <option value="devices">Devices</option>
                            <option value="info">Info Internetworks</option>
                            <option value="intelligence">Intelligence</option>
                            <option value="media">Media</option>
                            <option value="modsim">Modeling & Simulation</option>
                            <option value="people">People</option>
                            <option value="sysarc">Systems & Architecture</option>
                            <option value="theory">Theory</option>
                        </select>

                        <label htmlFor="thread2">Thread 2:</label>
                        <select class="walkthrough-buttons" name="thread2" id="thread2">
                            <option value="devices">Devices</option>
                            <option value="info">Info Internetworks</option>
                            <option value="intelligence">Intelligence</option>
                            <option value="media">Media</option>
                            <option value="modsim">Modeling & Simulation</option>
                            <option value="people">People</option>
                            <option value="sysarc">Systems & Architecture</option>
                            <option value="theory">Theory</option>
                        </select>

                        <input type="button" class="walkthrough-buttons" onClick={makeClasses} value="Set Threads" />
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