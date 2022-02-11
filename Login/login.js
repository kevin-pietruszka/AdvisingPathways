function check(form) {
    username = form.username.value
    password = form.password.value
    
    if (form.username.value == "Ting" && form.password.value == "123456") {
        location.replace('final_page.html')
    }else if (form.username.value == "" && form.password.value == "") {
        alert("You have left one or more info box empty, please enter your username and password.")
    }else if (form.username.value != "Ting" || form.password.value != "123456") {
        alert("Incorrect username or password, please try again.")
    }
    
}