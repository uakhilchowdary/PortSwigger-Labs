/**
 * Windows 95/98 Portfolio - Component System
 */

// Global cache for site configuration
let siteConfig = null;

// DOM element selection helper - Make these globally available
window.$ = (selector, parent = document) => parent.querySelector(selector);
window.$$ = (selector, parent = document) => parent.querySelectorAll(selector);

function insertHTML(element, position, html) {
    if (!element) return;
    element.insertAdjacentHTML(position, html);
}

async function loadSiteConfig() {
    if (siteConfig) return siteConfig;
    
    try {
        const response = await fetch('data/config.json');
        if (!response.ok) {
            throw new Error(`Failed to load config.json: ${response.status}`);
        }
        
        siteConfig = await response.json();
        return siteConfig;
    } catch (error) {
        console.error('Failed to load site configuration:', error);
        return {
            pages: {
                'index': {
                    pageName: "Portfolio",
                    statusText: "Welcome to my portfolio!",
                    activePage: "index"
                }
            }
        };
    }
}

async function createWindowHeader(pageName) {
    const windowHeaderHTML = `
        <div class="window-titlebar active">
            <div class="window-titlebar-icon"></div>
            <div class="window-titlebar-text">${pageName}</div>
            <div class="window-controls">
                <button class="window-control window-minimize">_</button>
                <button class="window-control window-maximize">□</button>
                <button class="window-control window-close">×</button>
            </div>
        </div>
    `;
    
    document.querySelectorAll('.portfolio-window').forEach(windowElement => {
        const existingHeader = windowElement.querySelector('.window-titlebar');
        if (existingHeader) {
            existingHeader.outerHTML = windowHeaderHTML;
        } else {
            windowElement.insertAdjacentHTML('afterbegin', windowHeaderHTML);
        }
    });
}

function createMainNavigation(activePage) {
    if (activePage === 'index') return;
    
    const navigationLinks = [
        { name: "HOME", url: "index.html" },
        { name: "ABOUT", url: "about.html" },
        { name: "EXPERIENCE", url: "experience.html" },
        { name: "PROJECTS", url: "projects.html" },
        { name: "BLOG", url: "blogs.html" },
        { name: "CONTACT", url: "contact.html" }
    ];
    
    const navigationHTML = `<div class="main-nav">${
        navigationLinks.map(link => {
            const isActivePage = link.url.includes(activePage);
            return `<a href="${link.url}" class="${isActivePage ? 'active-page' : ''}">${link.name}</a>`;
        }).join('')
    }</div>`;
    
    document.querySelectorAll('.content-area').forEach(contentArea => {
        const oldHomeLink = contentArea.querySelector('.corner-home-link');
        if (oldHomeLink) oldHomeLink.remove();
        
        const existingNav = contentArea.querySelector('.main-nav');
        if (existingNav) existingNav.remove();
        
        contentArea.insertAdjacentHTML('afterbegin', navigationHTML);
    });
}

function createWindowStatusbar(statusText) {
    const statusbarHTML = `
        <div class="window-statusbar">
            <div>${statusText}</div>
        </div>
    `;
    
    document.querySelectorAll('.portfolio-window').forEach(windowElement => {
        const existingStatusbar = windowElement.querySelector('.window-statusbar');
        if (existingStatusbar) {
            existingStatusbar.outerHTML = statusbarHTML;
        } else {
            windowElement.insertAdjacentHTML('beforeend', statusbarHTML);
        }
    });
}

async function getCurrentPageInfo() {
    const currentPath = window.location.pathname;
    
    const config = await loadSiteConfig();
    const pageConfigs = config.pages || {};
    
    const defaultConfigs = {
        'index': {
            pageName: "Portfolio",
            statusText: "Press F1 for help or use navigation to explore sections",
            activePage: "index"
        },
        'about': {
            pageName: "About",
            statusText: "Learn about my background, education, and skills",
            activePage: "about"
        }
    };
    
    if (currentPath.includes('index.html') || currentPath.endsWith('/') || currentPath.endsWith('/html/')) {
        return pageConfigs['index'] || defaultConfigs['index'];
    }
    
    for (const key of Object.keys(pageConfigs)) {
        if (currentPath.includes(`${key}.html`)) {
            return pageConfigs[key];
        }
    }
    
    return pageConfigs['index'] || defaultConfigs['index'];
}

function setupContentPageFullscreen(activePage) {
    if (activePage === "index") {
        document.body.classList.remove('content-page');
        const portfolioWindow = document.querySelector('.portfolio-window');
        if (portfolioWindow) {
            portfolioWindow.classList.remove('content-page-window');
        }
        return;
    }
    
    document.body.classList.add('content-page');
    
    const portfolioWindow = document.querySelector('.portfolio-window');
    if (!portfolioWindow) return;
    
    portfolioWindow.classList.add('content-page-window');
    portfolioWindow.style.transition = 'none';
    
    void portfolioWindow.offsetWidth;
    
    setTimeout(() => {
        portfolioWindow.style.transition = '';
        setupTitlebarTriggers();
        
        if (sessionStorage.getItem('navLinkClicked') !== 'true') {
            const titlebar = document.querySelector('.window-titlebar');
            if (titlebar) {
                titlebar.style.transform = 'translateY(-100%)';
            }
        }
    }, 50);
}

function setupTitlebarTriggers() {
    function showTitlebarImmediately() {
        const titlebar = document.querySelector('.window-titlebar');
        if (titlebar) {
            titlebar.style.transform = 'translateY(0)';
            titlebar.style.boxShadow = '0 2px 6px rgba(0, 0, 0, 0.3)';
        }
    }
    
    function hideTitlebar() {
        const titlebar = document.querySelector('.window-titlebar');
        if (titlebar) {
            titlebar.style.transform = 'translateY(-100%)';
            titlebar.style.boxShadow = 'none';
        }
    }
    
    const clickVisibilityDuration = 3000;
    
    window.lastTitlebarClickTime = Date.now();
    window.lastMouseMoveTime = Date.now();
    
    const titlebar = document.querySelector('.window-titlebar');
    if (titlebar) {
        titlebar.addEventListener('click', () => {
            window.lastTitlebarClickTime = Date.now();
        });
    }
    
    const contentArea = document.querySelector('.window-content');
    if (contentArea) {
        contentArea.addEventListener('mousemove', function(e) {
            const rect = contentArea.getBoundingClientRect();
            const distanceFromTop = e.clientY - rect.top;
            
            if (distanceFromTop < 40) {
                showTitlebarImmediately();
                window.lastTitlebarClickTime = Date.now();
            } else {
                hideTitlebar();
            }
        });
        
        contentArea.addEventListener('click', function(e) {
            const rect = contentArea.getBoundingClientRect();
            const distanceFromTop = e.clientY - rect.top;
            
            if (distanceFromTop < 60) {
                showTitlebarImmediately();
                window.lastTitlebarClickTime = Date.now();
            }
        });
    }
    
    document.addEventListener('mousemove', (e) => {
        window.lastMouseMoveTime = Date.now();
        
        if (e.clientY < 20) {
            showTitlebarImmediately();
        }
    });
    
    document.querySelectorAll('a[href$=".html"]').forEach(link => {
        link.addEventListener('click', (e) => {
            sessionStorage.setItem('navLinkClicked', 'true');
            showTitlebarImmediately();
            window.lastTitlebarClickTime = Date.now();
        });
    });
    
    showTitlebarImmediately();
    window.lastTitlebarClickTime = Date.now();
    
    setTimeout(() => {
        const now = Date.now();
        if (now - window.lastTitlebarClickTime >= clickVisibilityDuration) {
            hideTitlebar();
        }
    }, 1000);
}

async function initPageComponents() {
    const { pageName, statusText, activePage } = await getCurrentPageInfo();
    
    await createWindowHeader(pageName);
    createMainNavigation(activePage);
    createWindowStatusbar(statusText);
    setupContentPageFullscreen(activePage);
}

function showWindowTitleBar() {
    const titlebar = document.querySelector('.window-titlebar');
    if (titlebar) {
        titlebar.style.transform = 'translateY(0)';
        titlebar.style.boxShadow = '0 2px 6px rgba(0, 0, 0, 0.3)';
        window.lastTitlebarClickTime = Date.now();
    }
}

// Export the components API
window.Components = {
    initPageComponents,
    createWindowHeader,
    createMainNavigation,
    createWindowStatusbar,
    getCurrentPageInfo,
    loadSiteConfig,
    setupTitlebarTriggers,
    showWindowTitleBar
};