import React from "react";
import Sting from "./sting.jpg";
import { useNavigate } from "react-router-dom";

function Home() {

    const nav = useNavigate();

    const surveyChange = () =>{ 
        let path = `/survey`; 
        nav(path);
    }

    return (
        <>
            <head>
                <title>Home</title>
            </head>
            <body>
                <div id="head-bar">
                    <h7>Georgia Tech</h7>
                </div>

                <div id="page-title">
                    <h8>Advising Pathways</h8>
                </div>

                <div class="home-page">
                    <img src={Sting} alt="Gatech" id="sting" />
                    <h1>Login succeeded, welcome to Georgia Tech Advising System! What would you like to do today?</h1>

                    <form action="/walkthrough" method="post">
                        <input type="submit" name="pathway" class="exploreButton exploreClicked" value="Explore New Pathway" />
                    </form>
                    <input type="button" name="curriculum" class="curriculumButton curriculumClicked" value="New Curriculum Profile" />

                    
                    <input type="button" name="interests" class="interestsButton interestsClicked" value="Explore Interests" onClick={surveyChange}/>
                    

                    <form action="https://advisor.gatech.edu/">
                        <input type="submit" name="appointment" class="appointmentButton appointmentClicked" value="Schedule Advising Appointment" />
                    </form>

                    <div class="forget3">
                        <a href="index.html">Log out</a>
                    </div>

                </div>
            </body>
        </>
    );
}

export default Home;