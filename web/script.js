const installCommand = document.getElementById('installCommand')?.textContent?.trim() ?? './scripts/install-app.sh';
const downloadLink = document.getElementById('downloadCommand')?.textContent?.trim() ??
  'https://github.com/sushilbalami/clipboard-history/releases/latest/download/Clipboard-History-macOS.zip';

const copyButtons = [
  {
    button: document.getElementById('copyInstallCommand'),
    text: installCommand
  },
  {
    button: document.getElementById('copyDownloadLink'),
    text: downloadLink
  }
].filter(({ button }) => Boolean(button));

async function copyInstallText(button, text) {
  const originalLabel = button.textContent;

  try {
    await navigator.clipboard.writeText(text);
    button.textContent = 'Copied';
  } catch {
    button.textContent = 'Copy failed';
  }

  window.setTimeout(() => {
    button.textContent = originalLabel;
  }, 1800);
}

for (const item of copyButtons) {
  item.button.addEventListener('click', () => copyInstallText(item.button, item.text));
}

const year = document.getElementById('year');
if (year) {
  year.textContent = String(new Date().getFullYear());
}
