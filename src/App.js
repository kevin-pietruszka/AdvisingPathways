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
