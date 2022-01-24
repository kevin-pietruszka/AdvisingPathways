function newuser(form) {
	if (form.username.value != "" && form.email.value != "" 
        && form.password.value != "" && form.cPassword.value != "") {
        location.replace('final_page.html')
    } else {
        alert("Form is not completed.")
    }
}