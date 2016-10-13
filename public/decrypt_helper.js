(function(win) {
    window.password_prompt = function(label_message, button_message, arg3, arg4, arg5) {

        if (typeof label_message !== "string") var label_message = "Password:";
        if (typeof button_message !== "string") var button_message = "Submit";
        if (typeof arg3 === "function") {
            var callback = arg3;
        } else if (typeof arg3 === "number" && typeof arg4 === "number" && typeof arg5 === "function") {
            var width = arg3;
            var height = arg4;
            var callback = arg5;
        }
        if (typeof width !== "number") var width = 200;
        if (typeof height !== "number") var height = 100;
        if (typeof callback !== "function") var callback = function(password) {};

        var submit = function() {
            callback(input.value);
            document.body.removeChild(div);
            window.removeEventListener("resize", resize, false);
        };
        var resize = function() {
            div.style.left = ((window.innerWidth / 2) - (width / 2)) + "px";
            div.style.top = ((window.innerHeight / 2) - (height / 2)) + "px";
        };

        var div = document.createElement("div");
        div.id = "password_prompt";
        div.style.background = "white";
        div.style.color = "black";
        div.style.border = "1px solid black";
        div.style.width = width + "px";
        div.style.height = height + "px";
        div.style.padding = "16px";
        div.style.position = "fixed";
        div.style.left = ((window.innerWidth / 2) - (width / 2)) + "px";
        div.style.top = ((window.innerHeight / 2) - (height / 2)) + "px";

        var label = document.createElement("label");
        label.id = "password_prompt_label";
        label.innerHTML = label_message;
        label.for = "password_prompt_input";
        div.appendChild(label);

        div.appendChild(document.createElement("br"));

        var input = document.createElement("input");
        input.id = "password_prompt_input";
        input.type = "password";
        input.addEventListener("keyup", function(e) {
            if (event.keyCode == 13) submit();
        }, false);
        div.appendChild(input);

        div.appendChild(document.createElement("br"));
        div.appendChild(document.createElement("br"));

        var button = document.createElement("button");
        button.innerHTML = button_message;
        button.addEventListener("click", submit, false);
        div.appendChild(button);

        document.body.appendChild(div);
        window.addEventListener("resize", resize, false);
    };

    if (window.App.frontend_password == "true") {
        console.log('need password to decrypt message');
        window.password_prompt('Enter password to view this message, please', 'Submit', decryptMessage);
    } else {
        console.log('message is not encrypted');
        document.write("<p><b>Message: </b>" + window.App.raw_message);
    };

    function decryptMessage(password) {
        console.log('passowrd: ' + password);
        triplesec.decrypt({
            data: new triplesec.Buffer(window.App.raw_message, "hex"),
            key: new triplesec.Buffer(password)
        }, function(err, buff) {
            if (!err) {
                console.log("decrypted message: " + buff.toString());
                document.write("<p><b>Message:</b> " + buff.toString().replace(/\n/g, "<br>") + "</p>");
            } else {
                window.password_prompt('Incorrect password. Enter password to view this message, please', 'Submit', decryptMessage);
            }
        });
    };
}(window));