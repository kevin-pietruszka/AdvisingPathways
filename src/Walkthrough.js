import React, { useEffect, useState } from "react";

const curriculums = [];

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

    function makeClasses() {
        const classGet = [];
        let checker = true;

        let choice = getThread("thread1");
        for (let a = 0; a < threads[choice].length; a++) {
            for (let b = 1; b < threads[choice][a].length; b++) {
                classGet.push(threads[choice][a][b]);                
            }

        }

        choice = getThread("thread2");
        for (let a = 0; a < threads[choice].length; a++) {
            for (let b = 1; b < threads[choice][a].length; b++) {
                if (!classGet.includes(threads[choice][a][b])) {
                    classGet.push(threads[choice][a][b]);
                }
            }

        }

        choice = "core";
        for (let a = 0; a < threads[choice].length; a++) {
            for (let b = 1; b < threads[choice][a].length; b++) {
                if (!classGet.includes(threads[choice][a][b])) {
                    classGet.push(threads[choice][a][b]);
                }
            }

        }        
        setClasses(classGet);
    }

    function checkOffer(testClass) {
        if (takenClasses.includes(testClass)) {
            return false;
        }

        for (let ent in prereq) {
            if (ent == testClass) {
                let count = prereq[testClass].length;
                let counter = 0;
                for (let a = 0; a < prereq[testClass].length; a++) {
                    if (prereq[testClass][0].length == 0) {
                        return true;
                    }
                    let watcher = false;
                    for (let b = 0; b < prereq[testClass][a].length; b++) {
                        if (takenClasses.includes(prereq[testClass][a][b])) {
                            watcher = true;
                        }
                    }

                    if (watcher) {
                        counter++;
                    }
                }

                if (counter < count) {
                    return false;
                }
            }
        }
        
        return true;
    }

    function getChoices() {
        const choiceGet = [];
        for (let i = 0; i < classes.length; i++) {
            if (checkOffer(classes[i])) {
                choiceGet.push(classes[i]);
            }
        }
        setChoices(choiceGet);
    }

    function clearChoices() {
        setChoices(choiceClear);
        setChoosing(choiceClear);
        setSemesters(choiceClear);
        setTaken(choiceClear);
        setClasses(choiceClear);
        /*window.location.reload();*/
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

    function saveCurriculum () {
        let currNew = [];
        let num = curriculums.length + 1;
        curriculums.push(["Curriculum " + num, [semesters]]);
        console.log(curriculums);

        setUpdater(choiceClear);
    }

    function loadCurriculum() {
        
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
                        <input type="button" class="walkthrough-buttons" onClick={saveCurriculum} value="Save Curriculum" />

                        <div>
                            {curriculums.map((save) => (
                                <div key={Math.random()}>
                                    <input type="button" class="saves" value={save[0]} />
                                </div>
                            ))}
                        </div>
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