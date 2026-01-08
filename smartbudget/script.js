document.addEventListener('DOMContentLoaded', () => {
  // ======== GLOBAL VARIABLES ========
  const pages = document.querySelectorAll('.page');
  const navLinks = document.querySelectorAll('nav .nav-link');
  const sideLinks = document.querySelectorAll('.sidebar .side-link');
  const transactionTableBody = document.querySelector('#transactionsTable tbody');
  const categoryList = document.querySelectorAll('#categoryBreakdownList li');

  // Add transaction form elements
  const addTransactionForm = document.getElementById('addTransactionForm');
  const addDate = document.getElementById('addDate');
  const addDesc = document.getElementById('addDesc');
  const addAmount = document.getElementById('addAmount');
  const addCategory = document.getElementById('addCategory');

  // Edit transaction form elements
  const editWrapper = document.getElementById('editTransactionWrapper');
  const editForm = document.getElementById('editTransactionForm');
  const editDate = document.getElementById('editDate');
  const editDesc = document.getElementById('editDesc');
  const editAmount = document.getElementById('editAmount');
  const editCategory = document.getElementById('editCategory');
  const cancelEditBtn = document.getElementById('cancelEditBtn');

  // Review popup and star rating
  const openPopupBtn = document.querySelector('.open-review-btn');
  const reviewPopup = document.getElementById('reviewPopup');
  const closePopupBtn = document.getElementById('closeReviewPopup');
  const reviewForm = document.getElementById('reviewForm');
  const stars = document.querySelectorAll('#starRating .star');
  const selectedRatingInput = document.getElementById('selectedRating');
  const reviewsTrack = document.getElementById('reviewsTrack');
  const reviewCountEl = document.getElementById('reviewCount');
  const carouselLeft = document.getElementById('carouselLeft');
  const carouselRight = document.getElementById('carouselRight');

  // Calendar
  const calendarEl = document.getElementById('calendar');
  let currentCalendarDate = new Date();

  // Search
  const searchInput = document.getElementById('searchInput');

  // Profile and auth modal
  const profileIcon = document.getElementById('profileIcon');
  const authModal = document.getElementById('authModal');
  const authForm = document.getElementById('authForm');
  const toggleAuth = document.getElementById('toggleAuth');
  const toggleAuthText = document.getElementById('toggleAuthText');
  const modalTitle = document.getElementById('modalTitle');
  const modalSubtitle = document.getElementById('modalSubtitle');
  const authBtn = document.getElementById('authBtn');
  const ctaSignupBtn = document.getElementById('ctaSignupBtn');
  const loginFields = document.getElementById('loginFields');
  const registerFields = document.getElementById('registerFields');
  const forgotPasswordLink = document.getElementById('forgotPasswordLink');

  // Password toggle
  const togglePassword = document.getElementById('togglePassword');
  const toggleRegPassword = document.getElementById('toggleRegPassword');
  const toggleConfirmPassword = document.getElementById('toggleConfirmPassword');

  // FAQ Accordion
  const faqItems = document.querySelectorAll('.faq-item');

  // Hero slideshow
  const heroSlides = document.querySelectorAll('.hero-slide');
  let currentSlide = 0;

  // Data & state
  let transactions = JSON.parse(localStorage.getItem('transactions')) || [];
  let reviews = JSON.parse(localStorage.getItem('reviews')) || [];
  let users = JSON.parse(localStorage.getItem('users')) || [];
  let loggedInUser = JSON.parse(localStorage.getItem('loggedInUser')) || null;

  let isLogin = true;
  let selectedRating = 0;
  let currentEditIndex = null;
  let categoryChartInstance = null;

  // Helper functions
  function saveUsers() {
    localStorage.setItem('users', JSON.stringify(users));
  }

  function saveLoggedInUser() {
    localStorage.setItem('loggedInUser', JSON.stringify(loggedInUser));
  }

  function saveTransactions() {
    localStorage.setItem('transactions', JSON.stringify(transactions));
  }

  function today() {
    const d = new Date();
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
  }

  // ================= HERO SLIDESHOW =================
  function startSlideshow() {
    if (heroSlides.length === 0) return;
    
    setInterval(() => {
      heroSlides[currentSlide].classList.remove('active');
      currentSlide = (currentSlide + 1) % heroSlides.length;
      heroSlides[currentSlide].classList.add('active');
    }, 5000);
  }

  // ================= PAGE NAVIGATION =================
  function showPage(pageId) {
    console.log('Showing page:', pageId);
    
    pages.forEach(page => {
      page.classList.remove('active');
      if (page.id === pageId) {
        page.classList.add('active');
      }
    });

    navLinks.forEach(link => {
      const linkPage = link.getAttribute('data-page');
      link.classList.toggle('active', linkPage === pageId);
    });

    sideLinks.forEach(link => {
      const href = link.getAttribute('href');
      if (href) {
        const hrefPage = href.substring(1);
        link.classList.toggle('active', hrefPage === pageId);
      }
    });

    window.scrollTo(0, 0);
  }

  navLinks.forEach(link => {
    link.addEventListener('click', e => {
      e.preventDefault();
      const targetPage = link.getAttribute('data-page');
      if (targetPage) {
        console.log('Nav link clicked:', targetPage);
        showPage(targetPage);
      }
    });
  });

  sideLinks.forEach(link => {
    link.addEventListener('click', e => {
      e.preventDefault();
      const href = link.getAttribute('href');
      if (href) {
        const targetPage = href.substring(1);
        console.log('Sidebar link clicked:', targetPage);
        showPage(targetPage);
      }
    });
  });

  // ================= TRANSACTIONS =================
  function renderTransactionsTable() {
    if (!transactionTableBody) return;
    transactionTableBody.innerHTML = '';

    if (transactions.length === 0) {
      transactionTableBody.innerHTML = `<tr><td colspan="5" style="text-align:center; padding:20px;">No transactions yet</td></tr>`;
      return;
    }

    transactions.forEach((txn, idx) => {
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td>${txn.date}</td>
        <td>${txn.description}</td>
        <td style="text-align:right;">MYR ${txn.amount.toFixed(2)}</td>
        <td>${txn.category}</td>
        <td>
          <button class="edit-btn" data-index="${idx}">Edit</button>
          <button class="delete-btn" data-index="${idx}">Delete</button>
        </td>
      `;
      transactionTableBody.appendChild(tr);
    });

    document.querySelectorAll('.edit-btn').forEach(btn => {
      btn.onclick = () => {
        currentEditIndex = Number(btn.dataset.index);
        const txn = transactions[currentEditIndex];
        editDate.value = txn.date;
        editDesc.value = txn.description;
        editAmount.value = txn.amount;
        editCategory.value = txn.category;
        
        // Show edit form and scroll to it
        editWrapper.style.display = 'block';
        editWrapper.scrollIntoView({ behavior: 'smooth', block: 'start' });
      };
    });

    document.querySelectorAll('.delete-btn').forEach(btn => {
      btn.onclick = () => {
        const delIndex = Number(btn.dataset.index);
        if (confirm('Are you sure you want to delete this transaction?')) {
          transactions.splice(delIndex, 1);
          saveTransactions();
          renderAll();
        }
      };
    });
  }

  addTransactionForm?.addEventListener('submit', e => {
    e.preventDefault();

    const date = addDate.value || today();
    const description = addDesc.value.trim();
    const amount = parseFloat(addAmount.value);
    const category = addCategory.value;

    if (!description || isNaN(amount) || amount <= 0 || !category) {
      alert('Please fill all fields correctly');
      return;
    }

    transactions.push({ date, description, amount, category });
    saveTransactions();
    renderAll();

    addTransactionForm.reset();
    alert('Transaction added successfully!');
  });

  editForm?.addEventListener('submit', e => {
    e.preventDefault();
    if (currentEditIndex !== null) {
      transactions[currentEditIndex] = {
        date: editDate.value,
        description: editDesc.value,
        amount: parseFloat(editAmount.value),
        category: editCategory.value
      };
      saveTransactions();
      renderAll();
      
      // Hide edit form
      editWrapper.style.display = 'none';
      currentEditIndex = null;
      alert('Transaction updated successfully!');
    }
  });

  cancelEditBtn?.addEventListener('click', () => {
    editWrapper.style.display = 'none';
    currentEditIndex = null;
  });

  // ================= SEARCH =================
  searchInput?.addEventListener('input', e => {
    const searchTerm = e.target.value.toLowerCase().trim();

    if (!searchTerm) {
      renderTransactionsTable();
      return;
    }

    const filtered = transactions.filter(txn =>
      txn.description.toLowerCase().includes(searchTerm) ||
      txn.category.toLowerCase().includes(searchTerm) ||
      txn.date.includes(searchTerm)
    );

    showPage('transactions');

    if (filtered.length === 0) {
      transactionTableBody.innerHTML = `<tr><td colspan="5" style="text-align:center; padding:20px;">No transactions found for "${searchTerm}"</td></tr>`;
    } else {
      transactionTableBody.innerHTML = '';
      filtered.forEach((txn) => {
        const idx = transactions.indexOf(txn);
        const tr = document.createElement('tr');
        tr.innerHTML = `
          <td>${txn.date}</td>
          <td>${txn.description}</td>
          <td style="text-align:right;">MYR ${txn.amount.toFixed(2)}</td>
          <td>${txn.category}</td>
          <td>
            <button class="edit-btn" data-index="${idx}">Edit</button>
            <button class="delete-btn" data-index="${idx}">Delete</button>
          </td>
        `;
        transactionTableBody.appendChild(tr);
      });

      document.querySelectorAll('.edit-btn').forEach(btn => {
        btn.onclick = () => {
          currentEditIndex = Number(btn.dataset.index);
          const txn = transactions[currentEditIndex];
          editDate.value = txn.date;
          editDesc.value = txn.description;
          editAmount.value = txn.amount;
          editCategory.value = txn.category;
          
          editWrapper.style.display = 'block';
          editWrapper.scrollIntoView({ behavior: 'smooth', block: 'start' });
        };
      });

      document.querySelectorAll('.delete-btn').forEach(btn => {
        btn.onclick = () => {
          const delIndex = Number(btn.dataset.index);
          if (confirm('Are you sure?')) {
            transactions.splice(delIndex, 1);
            saveTransactions();
            renderAll();
          }
        };
      });
    }
  });

  // ================= BUDGET SUMMARY =================
  function calculateTotals() {
    let income = 0;
    let expense = 0;

    transactions.forEach(t => {
      const amt = Number(t.amount);
      const cat = t.category.trim();

      if (cat === 'Income') {
        income += amt;
      } else if (['Food', 'Beauty', 'Transport', 'Utilities'].includes(cat)) {
        expense += amt;
      }
    });

    return { income, expense };
  }

  function renderBudgetSummary() {
    const { income, expense } = calculateTotals();

    const walletIncome = document.getElementById('walletIncome');
    const walletExpense = document.getElementById('walletExpense');
    const walletAmount = document.getElementById('walletAmount');

    if (walletIncome) walletIncome.textContent = `MYR ${income.toFixed(2)}`;
    if (walletExpense) walletExpense.textContent = `MYR ${expense.toFixed(2)}`;
    if (walletAmount) walletAmount.textContent = `MYR ${(income - expense).toFixed(2)}`;

    const summary = document.getElementById('transactionSummary');
    if (!summary) return;

    const now = new Date();
    const currentMonth = now.getMonth();
    const currentYear = now.getFullYear();
    const monthNames = ["January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"];

    let monthlyTransactions = 0;
    transactions.forEach(t => {
      const txnDate = new Date(t.date);
      if (txnDate.getMonth() === currentMonth && txnDate.getFullYear() === currentYear) {
        monthlyTransactions++;
      }
    });

    if (transactions.length > 0) {
      summary.innerHTML = `
        <strong>Total Transactions:</strong> ${transactions.length}<br>
        <strong>${monthNames[currentMonth]} ${currentYear}:</strong> ${monthlyTransactions} transactions
      `;
    } else {
      summary.textContent = 'No transactions yet';
    }
  }

  // ================= CATEGORY BREAKDOWN =================
  function updateCategoryBreakdown() {
    const totals = { Food: 0, Beauty: 0, Transport: 0, Utilities: 0 };

    transactions.forEach(t => {
      const cat = t.category.trim();
      const amt = Number(t.amount);
      if (totals.hasOwnProperty(cat)) totals[cat] += amt;
    });

    Object.keys(totals).forEach((cat, idx) => {
      const li = categoryList[idx];
      if (li) {
        const amountEl = li.querySelector('.category-amount');
        if (amountEl) amountEl.textContent = `MYR ${totals[cat].toFixed(2)}`;
      }
    });
  }

  // ================= REPORTS & INSIGHTS =================
  function renderReports() {
    const { income, expense } = calculateTotals();
    const insightsEl = document.getElementById('financialInsights');
    
    if (!insightsEl) return;

    if (income === 0 && expense === 0) {
      insightsEl.textContent = 'No data yet. Add transactions to see insights.';
      return;
    }

    const balance = income - expense;
    const savingsRate = income > 0 ? ((balance / income) * 100).toFixed(1) : 0;

    insightsEl.innerHTML = `
      <strong>Financial Overview:</strong><br>
      Total Income: MYR ${income.toFixed(2)}<br>
      Total Expenses: MYR ${expense.toFixed(2)}<br>
      Current Balance: MYR ${balance.toFixed(2)}<br>
      Savings Rate: ${savingsRate}%<br><br>
      ${balance > 0 ? 
        '<strong style="color: #5a8f5a;">Great job!</strong> You\'re saving money.' : 
        '<strong style="color: #d9534f;">Warning:</strong> Your expenses exceed your income.'}
    `;
  }

  // ================= CHART =================
  function renderChart() {
    const ctx = document.getElementById('categoryChart');
    if (!ctx) return;

    const { income, expense } = calculateTotals();

    if (income === 0 && expense === 0) {
      if (categoryChartInstance) categoryChartInstance.destroy();
      return;
    }

    const data = [income, expense];

    if (categoryChartInstance) categoryChartInstance.destroy();

    categoryChartInstance = new Chart(ctx, {
      type: 'pie',
      data: {
        labels: ['Income', 'Expense'],
        datasets: [{
          data,
          backgroundColor: ['#f1c240ff', '#7c3b99ff'],
          borderColor: '#fff',
          borderWidth: 2
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: true,
        plugins: {
          legend: {
            position: 'bottom',
            labels: { font: { size: 12 } }
          },
          tooltip: {
            callbacks: {
              label: context => `${context.label}: MYR ${context.raw.toFixed(2)}`
            }
          }
        }
      }
    });
  }

  // ================= CALENDAR =================
  function renderCalendar() {
    if (!calendarEl) return;

    const year = currentCalendarDate.getFullYear();
    const month = currentCalendarDate.getMonth();
    const firstDay = new Date(year, month, 1).getDay();
    const lastDate = new Date(year, month + 1, 0).getDate();

    calendarEl.innerHTML = '';

    const monthNames = ["January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"];
    const headerDiv = document.createElement('div');
    headerDiv.classList.add('calendar-header');
    headerDiv.innerHTML = `
      <button id="prevMonth" style="background:#596549; color:white; border:none; padding:5px 10px; border-radius:5px; cursor:pointer;">◀</button>
      <span style="font-weight:bold;">${monthNames[month]} ${year}</span>
      <button id="nextMonth" style="background:#596549; color:white; border:none; padding:5px 10px; border-radius:5px; cursor:pointer;">▶</button>
    `;
    calendarEl.appendChild(headerDiv);

    document.getElementById('prevMonth').onclick = () => {
      currentCalendarDate.setMonth(currentCalendarDate.getMonth() - 1);
      renderCalendar();
    };

    document.getElementById('nextMonth').onclick = () => {
      currentCalendarDate.setMonth(currentCalendarDate.getMonth() + 1);
      renderCalendar();
    };

    const grid = document.createElement('div');
    grid.classList.add('calendar-grid');

    const dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    dayNames.forEach(d => {
      const dayEl = document.createElement('div');
      dayEl.classList.add('calendar-day-name');
      dayEl.textContent = d;
      grid.appendChild(dayEl);
    });

    for (let i = 0; i < firstDay; i++) {
      const blank = document.createElement('div');
      blank.classList.add('calendar-day', 'blank');
      grid.appendChild(blank);
    }

    for (let d = 1; d <= lastDate; d++) {
      const dayEl = document.createElement('div');
      dayEl.classList.add('calendar-day');
      const dateStr = `${year}-${String(month + 1).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
      const hasTxn = transactions.some(t => t.date === dateStr);

      if (hasTxn) {
        dayEl.classList.add('has-transaction', 'clickable');
        dayEl.onclick = () => {
          const dayTxns = transactions.filter(t => t.date === dateStr);
          alert(`Transactions on ${dateStr}:\n` +
            dayTxns.map(t => `${t.category}: MYR ${t.amount.toFixed(2)} - ${t.description}`).join('\n'));
        };
      }

      dayEl.textContent = d;
      grid.appendChild(dayEl);
    }

    calendarEl.appendChild(grid);
  }

  // ================= REVIEWS =================
  function addReviewToCarousel(review) {
    if (!reviewsTrack) return;
    const div = document.createElement('div');
    div.className = 'review-card';
    div.innerHTML = `
      <h4>${review.name}</h4>
      <div class="stars">${'⭐'.repeat(review.rating)}</div>
      <p>${review.comment}</p>
    `;
    reviewsTrack.appendChild(div);
  }

  reviews.forEach(addReviewToCarousel);
  if (reviewCountEl) reviewCountEl.textContent = reviews.length;

  stars.forEach(star => {
    star.addEventListener('mouseover', () => {
      stars.forEach(s => s.classList.remove('hovered'));
      for (let i = 0; i < star.dataset.rating; i++) {
        stars[i].classList.add('hovered');
      }
    });

    star.addEventListener('mouseout', () => {
      stars.forEach(s => s.classList.remove('hovered'));
    });

    star.addEventListener('click', () => {
      selectedRating = parseInt(star.dataset.rating);
      selectedRatingInput.value = selectedRating;
      stars.forEach(s => s.classList.remove('selected'));
      for (let i = 0; i < selectedRating; i++) {
        stars[i].classList.add('selected');
      }
    });
  });

  openPopupBtn?.addEventListener('click', () => {
    if (reviewPopup) reviewPopup.style.display = 'flex';
  });

  closePopupBtn?.addEventListener('click', () => {
    if (reviewPopup) reviewPopup.style.display = 'none';
  });

  reviewForm?.addEventListener('submit', e => {
    e.preventDefault();
    const name = document.getElementById('reviewerName').value.trim();
    const comment = document.getElementById('reviewComment').value.trim();

    if (selectedRating === 0) {
      alert('Please select a star rating!');
      return;
    }
    if (!name || !comment) {
      alert('Please fill all fields!');
      return;
    }

    const review = { name, rating: selectedRating, comment };
    reviews.push(review);
    localStorage.setItem('reviews', JSON.stringify(reviews));

    addReviewToCarousel(review);
    if (reviewCountEl) reviewCountEl.textContent = reviews.length;

    reviewForm.reset();
    stars.forEach(s => s.classList.remove('selected'));
    selectedRating = 0;
    if (reviewPopup) reviewPopup.style.display = 'none';
  });

  carouselLeft?.addEventListener('click', () => {
    if (reviewsTrack) reviewsTrack.scrollBy({ left: -270, behavior: 'smooth' });
  });

  carouselRight?.addEventListener('click', () => {
    if (reviewsTrack) reviewsTrack.scrollBy({ left: 270, behavior: 'smooth' });
  });

  // ================= AUTH MODAL =================
  function updateProfileUI() {
  if (loggedInUser) {
    profileIcon.textContent = `👋 Hi, ${loggedInUser.username}`;
  } else {
    profileIcon.textContent = '👤 Login';
  }
}

  function showAuthModal(loginMode) {
    isLogin = loginMode;
    if (loginMode) {
      loginFields.style.display = 'block';
      registerFields.style.display = 'none';
      modalTitle.textContent = 'Welcome back';
      modalSubtitle.textContent = 'Log in to pick up where you left off';
      authBtn.textContent = 'Log In';
      toggleAuthText.textContent = 'Not Registered?';
      toggleAuth.textContent = 'Create an Account';
    } else {
      loginFields.style.display = 'none';
      registerFields.style.display = 'block';
      modalTitle.textContent = 'Create Account';
      modalSubtitle.textContent = 'Sign up to start managing your budget';
      authBtn.textContent = 'Register';
      toggleAuthText.textContent = 'Already have an account?';
      toggleAuth.textContent = 'Log In';
    }
    authModal.classList.add('show');
  }

  toggleAuth?.addEventListener('click', e => {
    e.preventDefault();
    showAuthModal(!isLogin);
  });

  profileIcon?.addEventListener('click', () => {
    if (loggedInUser) {
      if (confirm('Log out from SmartBudget?')) {
        loggedInUser = null;
        saveLoggedInUser();
        updateProfileUI();
      }
    } else {
      showAuthModal(true);
    }
  });

  ctaSignupBtn?.addEventListener('click', () => {
    showAuthModal(false);
  });

  authForm?.addEventListener('submit', e => {
    e.preventDefault();

    if (isLogin) {
      const username = document.getElementById('username').value.trim();
      const password = document.getElementById('password').value.trim();

      if (!username || !password) {
        alert('Please fill all required fields');
        return;
      }

      const user = users.find(u => u.username === username && u.password === password);
      if (!user) {
        alert('Invalid username or password');
        return;
      }

      loggedInUser = user;
      saveLoggedInUser();
      alert(`Welcome back, ${user.username}!`);
      authModal.classList.remove('show');
      authForm.reset();
      updateProfileUI();
    } else {
      const regUsername = document.getElementById('regUsername').value.trim();
      const email = document.getElementById('regEmail').value.trim();
      const regPassword = document.getElementById('regPassword').value.trim();
      const confirmPassword = document.getElementById('confirmPassword').value.trim();
      const agreeTerms = document.getElementById('agreeTerms').checked;

      if (!regUsername || !email || !regPassword || !confirmPassword) {
        alert('Please fill all required fields');
        return;
      }

      if (regPassword !== confirmPassword) {
        alert('Passwords do not match');
        return;
      }

      if (!agreeTerms) {
        alert('Please agree to the Terms of Service');
        return;
      }

      if (users.find(u => u.username === regUsername)) {
        alert('Username already taken');
        return;
      }

      const newUser = { username: regUsername, email, password: regPassword };
      users.push(newUser);
      saveUsers();

      loggedInUser = newUser;
      saveLoggedInUser();
      updateProfileUI();
      alert(`Welcome, ${regUsername}!`);
      authModal.classList.remove('show');
      authForm.reset();
    }
  });

  togglePassword?.addEventListener('click', () => {
    const passwordInput = document.getElementById('password');
    passwordInput.type = passwordInput.type === 'password' ? 'text' : 'password';
  });

  toggleRegPassword?.addEventListener('click', () => {
    const regPasswordInput = document.getElementById('regPassword');
    regPasswordInput.type = regPasswordInput.type === 'password' ? 'text' : 'password';
  });

  toggleConfirmPassword?.addEventListener('click', () => {
    const confirmPasswordInput = document.getElementById('confirmPassword');
    confirmPasswordInput.type = confirmPasswordInput.type === 'password' ? 'text' : 'password';
  });

  forgotPasswordLink?.addEventListener('click', e => {
    e.preventDefault();
    alert('Password reset coming soon! Contact support@smartbudget.com');
  });

  // ================= FAQ ACCORDION =================
  faqItems.forEach(item => {
    const question = item.querySelector('.faq-question');
    question?.addEventListener('click', () => {
      const isActive = item.classList.contains('active');
      faqItems.forEach(faq => faq.classList.remove('active'));
      if (!isActive) item.classList.add('active');
    });
  });
  
  // Subscribe message handling
const subscribeBtn = document.querySelector('.footer-newsletter button');
const emailInput = document.querySelector('.footer-newsletter input[type="email"]');
const messageDiv = document.getElementById('subscribeMessage'); // Make sure you add this div in HTML

if (subscribeBtn && emailInput && messageDiv) {
  subscribeBtn.addEventListener('click', (e) => {
    e.preventDefault();
    if (emailInput.value.trim() === '') {
      messageDiv.style.color = 'red';
      messageDiv.textContent = 'Please enter a valid email.';
      messageDiv.style.display = 'block';
    } else {
      messageDiv.style.color = 'green';
      messageDiv.textContent = 'Thanks for subscribing!';
      messageDiv.style.display = 'block';
      emailInput.value = '';
    }
  });
}

  // ================= RENDER ALL =================
  function renderAll() {
    renderTransactionsTable();
    renderBudgetSummary();
    updateCategoryBreakdown();
    renderReports();
    renderChart();
    renderCalendar();
  }

  // ================= INITIAL RENDERS =================
  updateProfileUI();
  renderAll();
  startSlideshow();
  showPage('home');
});
