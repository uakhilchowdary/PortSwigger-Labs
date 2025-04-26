/**
 * Home Loader
 * 
 * A simple script that loads the name and roles from config.json
 * and updates the homepage elements.
 */

document.addEventListener('DOMContentLoaded', async function() {
    try {
        // Show window title bar if the Components API is available (though home page doesn't hide it)
        if (window.Components && window.Components.showWindowTitleBar) {
            window.Components.showWindowTitleBar();
        }
        
        // Fetch config.json data
        const response = await fetch('data/config.json');
        if (!response.ok) {
            throw new Error(`Failed to load config.json: ${response.status}`);
        }
        
        const data = await response.json();
        
        // Update name in the homepage heading
        const nameHeading = document.querySelector('.profile-heading h1');
        if (nameHeading) {
            const cursor = nameHeading.querySelector('.cursor');
            nameHeading.textContent = data.metadata.name;
            if (cursor) {
                nameHeading.appendChild(cursor);
            }
        }
        
        // Update roles rotation
        const roles = data.metadata.roles;
        if (roles && roles.length) {
            const roleText = document.getElementById('role-text');
            if (roleText) {
                roleText.textContent = roles[0];
                
                let roleIndex = 0;
                setInterval(() => {
                    roleText.textContent = roles[roleIndex];
                    roleIndex = (roleIndex + 1) % roles.length;
                }, 2000);
            }
        }
        
        // Update copyright text dynamically with current year
        const copyrightElement = document.querySelector('.copyright-footer');
        if (copyrightElement) {
            const currentYear = new Date().getFullYear();
            copyrightElement.textContent = `© Copyright ${currentYear} ${data.metadata.name}`;
        }
    } catch (error) {
        console.error('Failed to load data:', error);
    }
}); 