window.onload = function() {

    document.getElementById('mainForm').onsubmit = function() {
        var password = document.getElementById('password');
        var message = document.getElementById('message');
        alert('mess: ' + message.value + 'pass: ' + password.value);

        message.value = Aes.Ctr.encrypt(message.value, password.value, 256);

        password.value = '';
    };
};