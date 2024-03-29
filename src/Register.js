import React from "react";
import Sting from "./sting.jpg";

function Register() {
    return (
        <>
            <head>
                <meta charset="UTF-8"/>
                <title>Registration</title>
            </head>

            <body>
                <div class="main-page">
                    <img src={Sting} alt="Gatech" id="sting"/>

                    <h1>Create an Advising Pathways account</h1>

                    <form action="/register" method="post">
                        <h2>Username</h2>
                            <input type="userInput" name="username" class="user-name" />

                        <h4>Email</h4>
                            <input type="userEmail" name="email" class="user-email"/>

                        <h6>Password</h6>
                            <input type="rgUserPW" name="password" class="pass-word" />

                        <h5>Confirm Password</h5>
                            <input type="confirmPW" name="cPassword" class="c-pass-word"/>
                            <input type="submit" name="login" class="rglgButton rglgClicked" value="Register and Login"/>
                    </form>
      
                </div>
            </body>
        </>
    );
}

export default Register;