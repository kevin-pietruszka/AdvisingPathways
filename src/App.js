import React from "react";
import LoginPage from "./LoginPage";
import Register from "./Register";
import Home from "./Home";
import Walkthrough from "./Walkthrough";
import ThreadSurvey from "./survey";
import { Routes, Route, Link } from "react-router-dom";

function App() {
    
    return (
        <>
            <div id="head-bar">
                        <h7>Georgia Tech</h7>
            </div>
                <div id="page-title">
                    <h8>Advising Pathways</h8>
                </div>
                <div id="external-bar">
                    <h9><a href="/home">Home</a></h9>
                    <h10 class="external"> <a href="https://advisor.gatech.edu/">Advising Appointment</a></h10>
                    <h11 class="external"> <a href="/">Logout</a> </h11>
                </div>

            <Routes>
                <Route exact path="/" element={<LoginPage />} />
                <Route exact path="/reg" element={<Register />} />
                <Route exact path="/home" element={<Home />} />
                <Route exact path="/walkthrough" element={<Walkthrough />} />
                <Route exact path='/survey' element={<ThreadSurvey />} />
                </Routes>
        </>
    );
}

export default App;
