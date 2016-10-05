(function() {
    var form = document.forms["mainForm"];
    form.addEventListener("submit", encrypt);

    function encrypt(e) {
        e.preventDefault();
        var form = this;
        var password = document.getElementById('password');
        var message = document.getElementById('message');

        triplesec.encrypt({
            data: new triplesec.Buffer(message.value),
            key: new triplesec.Buffer(password.value)
        }, function(err, buff) {
            if (!err) {
                password.value = '';
                message.value = buff.toString('hex');
                console.log('message: ' + message.value);
                form.submit();
            } else {
                console.log("Error during ecrypting: " + err);
            }
        });
    }
}());