function newuser(form) {

    const fs = require("fs");

    const users = require("./users");

    console.log(fs.stringify(u))

    const user = null;

    if (form.username.value != "" || form.email.value != "" 
        || form.password.value != "" || form.cPassword.value != "") {

            for (u in users) {


                if (form.username.value == u.username) {
                    alert("Username is already taken, try again.")
                } else if (form.email.value == u.email) {
                    alert("Email is already associated with an account")
                }

            }

        
    } else {
        alert("Form is not completed.")
    }

    if (user != null) {
        users.push(user);
    }
    
    fs.writeFile("users.json", JSON.stringify(users), err => {
        if (err) throw err; 

        console.log("Users updated");
    });

    location.replace('homepage.html')

}