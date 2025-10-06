document.addEventListener('DOMContentLoaded', function() {

    // Run code based on which unique element is on the page
    if (document.getElementById('genes-table-body')) {
        loadGenes();
    }
    if (document.getElementById('traits-table-body')) {
        loadTraits();
    }
    if (document.getElementById('myPieChart')) {
        loadAnalyticsCharts();
    }
    if (document.getElementById('chat-window')) {
        setupChatbot();
    }

    // Update active nav link based on the current URL
    const currentPage = window.location.pathname;
    document.querySelectorAll('.sidebar .nav-link').forEach(link => {
        link.classList.remove('active');
        // Check if the link's href matches the current page's path
        if (link.getAttribute('href') === currentPage) {
            link.classList.add('active');
        } else if (currentPage === '/' && (link.getAttribute('href') === 'index.html' || link.getAttribute('href') === '/')) {
            // Special case for the root/index page
            link.classList.add('active');
        }
    });

    // --- Function to load and display Genes data ---
    async function loadGenes() {
        const tbody = document.getElementById('genes-table-body');
        tbody.innerHTML = '<tr><td colspan="4">Loading data...</td></tr>';
        try {
            const response = await fetch('/api/genes');
            if (!response.ok) throw new Error(`Network response was not ok: ${response.statusText}`);
            const genes = await response.json();
            
            tbody.innerHTML = '';
            
            if (genes.length === 0) {
                 tbody.innerHTML = '<tr><td colspan="4">No gene data found.</td></tr>';
                 return;
            }

            genes.forEach(gene => {
                const row = `
                    <tr>
                        <td><strong>${gene.gene_symbol}</strong></td>
                        <td>${gene.gene_name}</td>
                        <td>${gene.association_count}</td>
                        <td>${gene.description || 'N/A'}</td>
                    </tr>
                `;
                tbody.innerHTML += row;
            });
        } catch (error) {
            console.error('Failed to load genes:', error);
            tbody.innerHTML = `<tr><td colspan="4">Error loading data. See console for details.</td></tr>`;
        }
    }

    // --- Function to load and display Traits data ---
    async function loadTraits() {
        const tbody = document.getElementById('traits-table-body');
        tbody.innerHTML = '<tr><td colspan="4">Loading data...</td></tr>';
        try {
            const response = await fetch('/api/traits');
            if (!response.ok) throw new Error(`Network response was not ok: ${response.statusText}`);
            const traits = await response.json();

            tbody.innerHTML = '';

            if (traits.length === 0) {
                 tbody.innerHTML = '<tr><td colspan="4">No trait data found.</td></tr>';
                 return;
            }

            traits.forEach(trait => {
                const row = `
                    <tr>
                        <td><strong>${trait.trait_name}</strong></td>
                        <td>${trait.category}</td>
                        <td>${trait.inheritance_pattern}</td>
                        <td>${trait.gene_count}</td>
                    </tr>
                `;
                tbody.innerHTML += row;
            });
        } catch (error) {
            console.error('Failed to load traits:', error);
            tbody.innerHTML = `<tr><td colspan="4">Error loading data. See console for details.</td></tr>`;
        }
    }
    
    // --- Function to load all charts for the Analytics page ---
    async function loadAnalyticsCharts() {
        try {
            const response1 = await fetch('/api/charts/inheritance-patterns');
            const data1 = await response1.json();
            const pieChartCtx = document.getElementById('myPieChart');
            if (pieChartCtx) {
                new Chart(pieChartCtx.getContext('2d'), {
                    type: 'pie',
                    data: {
                        labels: data1.map(d => d.pattern),
                        datasets: [{
                            data: data1.map(d => d.count),
                            backgroundColor: ['#ff5a5f', '#087e8b', '#bfd7ea', '#0b3954', '#c81d25', '#f0a500'],
                            borderColor: '#fff',
                            borderWidth: 2
                        }]
                    }
                });
            }
        } catch (error) { console.error('Failed to load pie chart data:', error); }

        try {
            const response2 = await fetch('/api/charts/most-studied');
            const data2 = await response2.json();
            const barChartCtx = document.getElementById('myBarChart');
            if(barChartCtx) {
                new Chart(barChartCtx.getContext('2d'), {
                    type: 'bar',
                    data: {
                        labels: data2.map(d => d.gene),
                        datasets: [{
                            label: 'Number of Studies',
                            data: data2.map(d => d.studies),
                            backgroundColor: '#087e8b'
                        }]
                    },
                    options: {
                        plugins: { legend: { display: false } },
                        scales: { y: { beginAtZero: true } }
                    }
                });
            }
        } catch (error) { console.error('Failed to load bar chart data:', error); }
    }
    
    // --- Function to set up the chatbot ---
    function setupChatbot() {
        const chatWindow = document.getElementById('chat-window');
        const userInput = document.getElementById('user-input');
        const sendButton = document.getElementById('send-button');
        let sessionId = sessionStorage.getItem('geneverse_session_id') || null;

        if (chatWindow && userInput && sendButton) {
            sendButton.addEventListener('click', sendMessage);
            userInput.addEventListener('keypress', function(e) {
                if (e.key === 'Enter') { e.preventDefault(); sendMessage(); }
            });
        }

        async function sendMessage() {
            const messageText = userInput.value.trim();
            if (messageText === '') return;
            appendMessage(messageText, 'user-message');
            const userInputValue = userInput.value;
            userInput.value = '';
            try {
                const response = await fetch('/api/chatbot', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ message: userInputValue, session_id: sessionId }),
                });
                if (!response.ok) throw new Error(`Server error: ${response.statusText}`);
                const data = await response.json();
                if (data.session_id && !sessionId) {
                    sessionId = data.session_id;
                    sessionStorage.setItem('geneverse_session_id', sessionId);
                }
                appendMessage(data.response, 'bot-message');
            } catch (error) {
                console.error('Chatbot API error:', error);
                appendMessage('Sorry, I am having trouble connecting to the server.', 'bot-message');
            }
        }

        function appendMessage(text, className) {
            const messageDiv = document.createElement('div');
            messageDiv.classList.add('message', className);
            const p = document.createElement('p');
            p.textContent = text;
            messageDiv.appendChild(p);
            chatWindow.appendChild(messageDiv);
            chatWindow.scrollTop = chatWindow.scrollHeight;
        }
    }
});