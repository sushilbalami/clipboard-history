const installCommand = document.getElementById('installCommand')?.textContent?.trim() ?? './scripts/install-app.sh';
const copyButtons = [
  document.getElementById('copyInstallCommand'),
  document.getElementById('copyInstallCommandAlt')
].filter(Boolean);

async function copyInstallText(button) {
  const originalLabel = button.textContent;

  try {
    await navigator.clipboard.writeText(installCommand);
    button.textContent = 'Copied';
  } catch {
    button.textContent = 'Copy failed';
  }

  window.setTimeout(() => {
    button.textContent = originalLabel;
  }, 1800);
}

for (const button of copyButtons) {
  button.addEventListener('click', () => copyInstallText(button));
}

const year = document.getElementById('year');
if (year) {
  year.textContent = String(new Date().getFullYear());
}
