import React from "react";
import Sting from "./sting.jpg";

function LoginPage() {
    return (
        <>
            <div id="head-bar">
                <h1>Georgia Tech</h1>
            </div>

            <div id="page-title">
                <h8>Advising Pathways</h8>
            </div>

            <div class="main-page">
                <img src={Sting} alt="Gatech sting" id="sting"/>
                <h1>Enter your Advising Pathways Username and Password</h1>

                <form action="/auth" method="post">

                    <h2> Username </h2>
                    <input type="userInput" name="username" placeholder="Username" id="username" class="user-name" />
                    <h3> Password </h3>
                    <input type="userPW" name="password" class="pass-word" />
                    <input type="submit" name="login" class="lgButton lgClicked" value="Login" />

                </form>

                <form action="/signup" method = "post" >
                    <input type="submit" name="register" class="rgButton rgClicked" value="Register" />
                </form>

            </div>
        </>
    );
}

export default LoginPage;