(function(win) {
    var form = document.forms["mainForm"];
    form.addEventListener('submit', encrypt);

    function encrypt(e) {
        e.preventDefault();
        var visits_to_live = document.getElementsByName('visits_to_live')[0];
        var hours_to_live = document.getElementsByName('hours_to_live')[0];
        if (visits_to_live.value.length && hours_to_live.value.length) {
            alert("You should choose only one: number of link visits or number of hours")
        } else {
            var form = this;
            var password = document.getElementById('password');
            var message = document.getElementById('message');

            if (password.value) {
                triplesec.encrypt({
                    data: new triplesec.Buffer(message.value),
                    key: new triplesec.Buffer(password.value),
                    progress_hook: function() {
                        var message_input = document.getElementById('message_input');
                        message_input.style.visibility = 'hidden'
                        var loader = document.getElementById('loader');
                        loader.style.visibility = 'visible';
                    }
                }, function(err, buff) {
                    if (!err) {
                        console.log('message: ' + message.value);
                        password.value = 'true';
                        message.value = buff.toString('hex');
                        form.submit();
                    } else {
                        console.log("Error during ecrypting: " + err);
                    }
                });
            } else {
                console.log('password is empty, skipping ecryption');
                form.submit();
            }
        }
    }
}(window));