const installCommand = './scripts/install-app.sh';
const downloadLink = 'https://github.com/sushilbalami/clipboard-history/releases/latest/download/Clipboard-History-macOS.zip';

async function copyText(button, text, successLabel = 'Copied') {
  const originalLabel = button.textContent;

  try {
    await navigator.clipboard.writeText(text);
    button.textContent = successLabel;
  } catch {
    button.textContent = 'Copy failed';
  }

  window.setTimeout(() => {
    button.textContent = originalLabel;
  }, 1800);
}

function bindCopyButton(id, text, successLabel) {
  const button = document.getElementById(id);
  if (!button) {
    return;
  }

  button.addEventListener('click', () => {
    copyText(button, text, successLabel);
  });
}

function bindCopyAndRedirectButton(id, text, url) {
  const button = document.getElementById(id);
  if (!button) {
    return;
  }

  button.addEventListener('click', async () => {
    await copyText(button, text, 'Opening');
    window.open(url, '_blank', 'noopener,noreferrer');
  });
}

bindCopyButton('copyInstallCommand', installCommand, 'Copied');
bindCopyButton('copyDownloadLink', downloadLink, 'Copied');
bindCopyButton('copyDownloadLinkHero', downloadLink, 'Copied');

bindCopyAndRedirectButton('navDownloadLatest', downloadLink, downloadLink);
bindCopyAndRedirectButton('downloadLatestHero', downloadLink, downloadLink);
bindCopyAndRedirectButton('downloadLatestInstall', downloadLink, downloadLink);

const year = document.getElementById('year');
if (year) {
  year.textContent = String(new Date().getFullYear());
}
