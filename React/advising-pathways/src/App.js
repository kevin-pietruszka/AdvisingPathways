import React from "react";
import './App.css';
import LoginPage from "./LoginPage";
import Register from "./Register";
import Home from "./Home";
import { Routes, Route, Link } from "react-router-dom";

function App() {
    
    return (
        <Routes>
            <Route exact path="/" element={<LoginPage />} />
            <Route exact path="/reg" element={<Register />} />
            <Route exact path="/home" element={<Home />} />
        </Routes>
    );
}

export default App;
