// Optimized Theme System - Immediately applies theme and handles theme switching
(function() {
    // Get saved theme preference or check system preference
    const savedTheme = localStorage.getItem('theme');
    const shouldUseDarkTheme = savedTheme === 'dark' || 
                              (savedTheme === null && 
                               window.matchMedia && 
                               window.matchMedia('(prefers-color-scheme: dark)').matches);
    
    // Apply theme immediately to prevent flash
    if (shouldUseDarkTheme) {
        document.documentElement.classList.add('dark-theme');
        const style = document.createElement('style');
        style.textContent = 'body { background-color: var(--dark-bg-color); color: var(--dark-primary-white); }';
        document.head.appendChild(style);
        
        if (savedTheme === null) {
            localStorage.setItem('theme', 'dark');
        }
    }
    
    // DOM Ready handler
    window.addEventListener('DOMContentLoaded', function() {
        setTimeout(() => {
            document.documentElement.classList.add('transitions-enabled');
        }, 100);
        
        createThemeSwitcher(shouldUseDarkTheme);
    });
    
    /**
     * Creates and injects the theme switcher UI element
     */
    function createThemeSwitcher(isDarkTheme) {
        // Check if this is the first visit for animation purposes
        const isFirstVisit = !localStorage.getItem('theme_toggle_visited');
        const firstVisitClass = isFirstVisit ? 'first-visit' : '';
        
        // Create the toggle HTML
        const themeSwitcherHTML = `
            <div class="theme-switch-wrapper">
                <label class="theme-switch ${firstVisitClass}" for="theme-switch" title="Toggle theme">
                    <input type="checkbox" id="theme-switch" ${isDarkTheme ? 'checked' : ''}>
                </label>
            </div>
        `;
        
        // Insert at the beginning of the body
        document.body.insertAdjacentHTML('afterbegin', themeSwitcherHTML);
        
        // Mark as visited after a delay to allow animation to play
        if (isFirstVisit) {
            setTimeout(() => {
                localStorage.setItem('theme_toggle_visited', 'true');
            }, 2000);
        }
        
        // Set up the theme toggle functionality
        setupThemeToggle();
    }
    
    /**
     * Sets up the theme toggle change listener
     */
    function setupThemeToggle() {
        const themeToggle = document.getElementById('theme-switch');
        if (!themeToggle) return;
        
        themeToggle.addEventListener('change', function(e) {
            // Show titlebar when theme is toggled on content pages
            showTitlebarIfNeeded();
            
            // Apply the selected theme
            applyTheme(e.target.checked);
        });
    }
    
    /**
     * Shows the titlebar when theme is toggled (if on a content page)
     */
    function showTitlebarIfNeeded() {
        // Only run on content pages
        if (!window.Components || window.location.pathname.includes('index.html')) return;
        
        // Find and show the titlebar
        const titlebar = document.querySelector('.window-titlebar');
        if (!titlebar) return;
        
        // Position and style the titlebar
        titlebar.style.transform = 'translateY(0)';
        titlebar.style.boxShadow = '0 2px 6px rgba(0, 0, 0, 0.3)';
        
        // Update the click timestamp to prevent auto-hiding
        window.lastTitlebarClickTime = Date.now();
    }
    
    /**
     * Applies the selected theme to the document
     */
    function applyTheme(isDarkTheme) {
        if (isDarkTheme) {
            document.body.classList.add('dark-theme');
            document.documentElement.classList.add('dark-theme');
            localStorage.setItem('theme', 'dark');
        } else {
            document.body.classList.remove('dark-theme');
            document.documentElement.classList.remove('dark-theme');
            localStorage.setItem('theme', 'light');
        }
    }
})(); 