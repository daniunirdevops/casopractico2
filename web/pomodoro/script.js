let TOTAL = 25 * 60; // 25 minuts

let remaining = TOTAL;
let timer = null;
let running = false;

const r = 145;
const c = 2 * Math.PI * r;
const minutesInput = document.getElementById("minutesInput");
const progress = document.getElementById('progress');
progress.style.strokeDasharray = c;
progress.style.strokeDashoffset = 0;

const icon = document.getElementById('icon');
const time = document.getElementById('time');

function render() {
    // Actualitza la barra circular
    progress.style.strokeDashoffset =
        (1 - (remaining / TOTAL)) * c;

    // Calcula minuts i segons
    const minutes = Math.floor(remaining / 60);
    const seconds = remaining % 60;

    // Mostra el temps en format MM:SS
    time.textContent =
        `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;    
}

function start() {
    if (remaining === 0) {
        remaining = TOTAL;
    }
    running = true;
    icon.className = 'stop';

    timer = setInterval(() => {
        remaining--;

        render();

        if (remaining <= 0) {
            clearInterval(timer);

            remaining = 0;
            running = false;

            icon.className = 'play';

            render();
        }
    }, 1000);
}

function stop() {
    clearInterval(timer);

    running = false;
    icon.className = 'play';
}

function reset() {
    clearInterval(timer);

    running = false;
    TOTAL = parseInt(minutesInput.value) * 60;
    remaining = TOTAL;

    icon.className = 'play';

    render();
}

minutesInput.addEventListener("change", () => {
    if (!running) {
        TOTAL = parseInt(minutesInput.value) * 60;
        remaining = TOTAL;
        render();
    }
});

document.getElementById('reset')
        .addEventListener('click', reset);

document.getElementById('toggle').onclick = () => {
    if (running) {
        stop();
    } else {
        start();
    }
};

render();