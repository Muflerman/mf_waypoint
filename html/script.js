const container = document.getElementById('waypoint-container');
const distVal = document.getElementById('distance-val');
const distUnit = document.getElementById('distance-unit');
const destLabel = document.getElementById('destination-label');

let isFadingOut = false;

function clampChannel(value) {
    const n = Number(value);
    if (Number.isNaN(n)) return 0;
    return Math.max(0, Math.min(255, Math.round(n)));
}

function applyUIColor(color) {
    if (!color) return;

    const r = clampChannel(color.r);
    const g = clampChannel(color.g);
    const b = clampChannel(color.b);
    const root = document.documentElement;

    root.style.setProperty('--wp-accent', `rgb(${r}, ${g}, ${b})`);
    root.style.setProperty('--wp-accent-glow', `rgba(${r}, ${g}, ${b}, 0.85)`);
    root.style.setProperty('--wp-accent-glow-soft', `rgba(${r}, ${g}, ${b}, 0.4)`);
}

window.addEventListener('message', (event) => {
    const data = event.data;

    if (!data) return;

    if (data.action === 'setColor') {
        applyUIColor(data.color);
        return;
    }

    if (data.action === 'update') {
        if (!data.visible) {
            container.classList.add('hidden');
            return;
        }

        if (isFadingOut) {
            container.classList.remove('fade-out');
            isFadingOut = false;
        }

        container.classList.remove('hidden');

        // Text & Units
        distVal.textContent = data.dist;
        distUnit.textContent = data.unit || 'M';
        if (data.label) {
            destLabel.textContent = data.label;
        }

        // Screen Coordinates and Scale
        const scale = data.scale || 1.0;
        container.style.left = `${(data.x * 100).toFixed(2)}%`;
        container.style.top = `${(data.y * 100).toFixed(2)}%`;
        container.style.transform = `translate(-50%, -100%) scale(${scale.toFixed(3)})`;
    } 
    else if (data.action === 'arrived') {
        isFadingOut = true;
        container.classList.add('fade-out');
        setTimeout(() => {
            if (isFadingOut) {
                container.classList.add('hidden');
                container.classList.remove('fade-out');
                isFadingOut = false;
            }
        }, 300);
    } 
    else if (data.action === 'hide') {
        container.classList.add('hidden');
        container.classList.remove('fade-out');
        isFadingOut = false;
    }
});
