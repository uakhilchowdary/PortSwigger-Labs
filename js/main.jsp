/**
 * Windows 95/98 Portfolio - Main JavaScript
 */

// DOM helper functions
const $ = (selector, parent = document) => parent.querySelector(selector);
const $$ = (selector, parent = document) => parent.querySelectorAll(selector);
const onEvent = (element, event, handler) => element?.addEventListener(event, handler);
const addClassWithReflow = (element, className) => {
    element?.classList.add(className);
    void element?.offsetWidth; // Force a reflow
};

function initializeWindowControls() {
    document.addEventListener('click', (e) => {
        if (e.target.classList.contains('window-close')) {
            if (isHomePage()) {
                alert('Thanks for visiting! (Window close simulated)');
            } else {
                animateToHomePage();
            }
        } else if (e.target.classList.contains('window-minimize')) {
            alert('Window minimized (simulated)');
        } else if (e.target.classList.contains('window-maximize')) {
            alert('Window maximized (simulated)');
        }
    });
}

function isHomePage() {
    return window.location.pathname.includes('index.html') || 
           window.location.pathname.endsWith('/') || 
           window.location.pathname.endsWith('/html/');
}

function updateCopyrightYear() {
    const yearElement = document.getElementById('current-year');
    if (yearElement) {
        yearElement.textContent = new Date().getFullYear();
    }
}

function setupPageTransitions() {
    const portfolioWindow = document.querySelector('.portfolio-window');
    
    if (!portfolioWindow) return;
    
    if (isHomePage()) {
        setupHomePageTransitions(portfolioWindow);
    } else {
        setupContentPageTransitions(portfolioWindow);
    }
}

function setupHomePageTransitions(portfolioWindow) {
    portfolioWindow.classList.remove('content-page-window');
    
    document.querySelectorAll('.horizontal-nav a, .main-nav a').forEach(link => {
        if (link.getAttribute('href')?.includes('.html')) {
            link.addEventListener('click', function(e) {
                e.preventDefault();
                const targetHref = link.getAttribute('href');
                
                sessionStorage.setItem('navLinkClicked', 'true');
                document.body.style.overflow = 'hidden';
                portfolioWindow.classList.add('zoom-to-fullscreen');
                
                setTimeout(() => {
                    window.location.href = targetHref;
                }, 500);
            });
        }
    });
}

function setupContentPageTransitions(portfolioWindow) {
    portfolioWindow.classList.add('content-page-window');
    
    document.querySelectorAll('a[href="index.html"], .page-nav-button[href="index.html"]').forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            sessionStorage.setItem('navLinkClicked', 'true');
            animateToHomePage();
        });
    });
    
    document.querySelectorAll('a[href$=".html"]:not([href="index.html"])').forEach(link => {
        if (!link.classList.contains('page-nav-button')) {
            link.addEventListener('click', function() {
                sessionStorage.setItem('navLinkClicked', 'true');
            });
        }
    });
}

function animateToHomePage() {
    const portfolioWindow = document.querySelector('.portfolio-window');
    
    const titlebar = document.querySelector('.window-titlebar');
    if (titlebar) {
        titlebar.style.transform = 'translateY(0)';
        titlebar.style.boxShadow = '0 2px 6px rgba(0, 0, 0, 0.3)';
        titlebar.style.pointerEvents = 'auto';
        titlebar.style.position = 'absolute';
        titlebar.style.width = '100%';
        titlebar.style.zIndex = '1001';
        titlebar.classList.add('visible-during-transition');
    }
    
    document.body.style.overflow = 'hidden';
    
    setTimeout(() => {
        portfolioWindow.classList.remove('content-page-window');
        void portfolioWindow.offsetWidth;
        portfolioWindow.classList.add('zoom-from-fullscreen');
        
        setTimeout(() => {
            window.location.href = 'index.html';
        }, 500);
    }, 10);
}

// Initialize all functionality when the DOM is fully loaded
document.addEventListener('DOMContentLoaded', async function() {
    try {
        if (window.Components) {
            await window.Components.initPageComponents();
        }
        
        initializeWindowControls();
        updateCopyrightYear();
        setupPageTransitions();
    } catch (error) {
        console.error('Error during initialization:', error);
    }
}); 