const awesome = document.querySelector('[data-element="awesome"]');
const intrinsicSwitch = document.querySelector("#intrinsic-switch");

// Set sizing attribute based on switch
intrinsicSwitch.addEventListener("change", () => {
  awesome.setAttribute(
    "data-sizing",
    intrinsicSwitch.checked ? "intrinsic" : "extrinsic"
  );
});

// Segundo ejemplo
const parentBox = document.querySelector('[data-element="parent-box"]');
const heightLabel = document.querySelector('[data-element="height-label"]');
const widthLabel = document.querySelector('[data-element="width-label"]');
const intrinsicSwitch2 = document.querySelector("#intrinsic-switch2");

// Update the size labels on resize
const observer = new ResizeObserver((observedItems) => {
  const { borderBoxSize } = observedItems[0];

  widthLabel.innerText = `${Math.round(borderBoxSize[0].inlineSize)}px`;
  heightLabel.innerText = `${Math.round(borderBoxSize[0].blockSize)}px`;
});

observer.observe(parentBox);

// Set sizing attribute based on switch
intrinsicSwitch2.addEventListener("change", () => {
  parentBox.setAttribute(
    "data-sizing",
    intrinsicSwitch2.checked ? "intrinsic" : "extrinsic"
  );
});
