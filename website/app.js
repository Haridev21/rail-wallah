import { initializeApp } from "https://www.gstatic.com/firebasejs/10.9.0/firebase-app.js";
import { getAuth, signInWithEmailAndPassword, onAuthStateChanged, signOut }
    from "https://www.gstatic.com/firebasejs/10.9.0/firebase-auth.js";
import { getFirestore, collection, onSnapshot, doc, updateDoc }
    from "https://www.gstatic.com/firebasejs/10.9.0/firebase-firestore.js";

// ✅ YOUR ORIGINAL FIREBASE CONFIG (RESTORED)
const firebaseConfig = {
    apiKey: "AIzaSyBTD2DP6O60vqUV1RPR4ZTZCO3N3foi9K8",
    appId: "1:348279615785:web:83fe20c480461ef5ad4738",
    messagingSenderId: "348279615785",
    projectId: "notification-d557e",
    authDomain: "notification-d557e.firebaseapp.com",
    storageBucket: "notification-d557e.firebasestorage.app",
    measurementId: "G-PJ6R3KF5GC"
};

// Init
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

// Detect pages
const isLoginPage = document.getElementById("login-form");
const isDashboardPage = document.getElementById("logout-btn");

// ================= LOGIN =================
if (isLoginPage) {
    const form = document.getElementById("login-form");
    const errorMsg = document.getElementById("login-error");

    form.addEventListener("submit", async (e) => {
        e.preventDefault();

        const email = document.getElementById("email").value.trim();
        const password = document.getElementById("password").value;

        try {
            await signInWithEmailAndPassword(auth, email, password);
            window.location.href = "dashboard.html";
        } catch (error) {
            console.log(error);
            errorMsg.textContent = "Invalid email or password";
            errorMsg.classList.remove("hidden");
        }
    });
}

// ================= DASHBOARD =================
if (isDashboardPage) {
    const logoutBtn = document.getElementById("logout-btn");
    const userEmail = document.getElementById("user-email");
    const tableBody = document.getElementById("table-body");
    const searchInput = document.getElementById("search-input");
    const statusFilter = document.getElementById("status-filter");
    const emptyState = document.getElementById("empty-state");
    const loadingState = document.getElementById("loading-state");

    // Modal elements
    const modal = document.getElementById("complaint-modal");
    const closeModalBtn = document.getElementById("close-modal");
    const modalBody = document.getElementById("modal-body");
    const updateStatusSelect = document.getElementById("update-status");
    const saveStatusBtn = document.getElementById("save-status-btn");
    
    // Toast elements
    const toast = document.getElementById("toast");

    let allComplaints = [];
    let currentComplaintId = null;

    // ✅ AUTH CHECK
    onAuthStateChanged(auth, (user) => {
        if (!user) {
            window.location.href = "index.html";
        } else {
            userEmail.textContent = user.email;
            loadComplaints();
        }
    });

    // ✅ LOGOUT
    logoutBtn.addEventListener("click", () => {
        signOut(auth).then(() => {
            window.location.href = "index.html";
        });
    });

    // ✅ LOAD FIRESTORE DATA
    function loadComplaints() {
        const ref = collection(db, "complaints");

        onSnapshot(ref, (snapshot) => {
            allComplaints = [];
            snapshot.forEach(doc => {
                allComplaints.push({ id: doc.id, ...doc.data() });
            });
            renderTable();
        });
    }

    // ✅ RENDER TABLE WITH FILTERS
    function renderTable() {
        if (loadingState) loadingState.classList.add("hidden");
        
        tableBody.innerHTML = "";
        
        const searchTerm = searchInput.value.toLowerCase();
        const filterStatus = statusFilter.value.toLowerCase();

        const filtered = allComplaints.filter(complaint => {
            const cStatus = (complaint.status || "Registered").toLowerCase();
            const cId = complaint.id.toLowerCase();
            const cPhone = (complaint.phoneNumber || complaint.phone || "").toLowerCase();
            
            // Apply search
            const matchesSearch = cId.includes(searchTerm) || cPhone.includes(searchTerm);
            
            // Apply filter
            const matchesFilter = filterStatus === "all" || cStatus === filterStatus;

            return matchesSearch && matchesFilter;
        });

        if (filtered.length === 0 && allComplaints.length > 0) {
            emptyState.classList.remove("hidden");
            emptyState.innerHTML = "<p>No matching complaints found</p>";
        } else if (allComplaints.length === 0) {
            emptyState.classList.remove("hidden");
            emptyState.innerHTML = "<p>No complaints yet</p>";
        } else {
            emptyState.classList.add("hidden");
            
            filtered.forEach(data => {
                let status = (data.status || "Registered").toLowerCase();
                const category = data.category || "N/A";
                const train = data.train_number || data.trainNumber || "N/A";
                const phone = data.phoneNumber || data.phone || "N/A";
                
                // Format date
                let dateStr = "N/A";
                if (data.timestamp) {
                    const d = data.timestamp.toDate ? data.timestamp.toDate() : new Date(data.timestamp);
                    dateStr = d.toLocaleDateString() + " " + d.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
                }

                let badgeClass = "status-registered";
                if (status === "in progress" || status === "pending") badgeClass = "status-pending";
                if (status === "resolved") badgeClass = "status-resolved";
                if (status === "closed") badgeClass = "status-closed";

                // Map 'in progress' correctly for display if needed
                let displayStatus = status.split(' ').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ');

                const row = document.createElement("tr");
                row.innerHTML = `
                    <td><strong>#${data.id.substring(0, 6).toUpperCase()}</strong></td>
                    <td>${category}</td>
                    <td>${train}</td>
                    <td>${phone}</td>
                    <td>${dateStr}</td>
                    <td><span class="status-badge ${badgeClass}">${displayStatus}</span></td>
                    <td><button class="icon-btn view-details-btn" data-id="${data.id}" title="View Details"><span class="material-icons-round">visibility</span></button></td>
                `;
                tableBody.appendChild(row);
            });
            
            // Attach event listeners to new buttons
            document.querySelectorAll(".view-details-btn").forEach(btn => {
                btn.addEventListener("click", (e) => {
                    const id = e.currentTarget.getAttribute("data-id");
                    openModal(id);
                });
            });
        }

        // Update stats top cards based on all data (not filtered data)
        const statTotal = document.getElementById("stat-total");
        const statPending = document.getElementById("stat-pending");
        const statResolved = document.getElementById("stat-resolved");
        
        if(statTotal) statTotal.textContent = allComplaints.length; 
        if(statPending) statPending.textContent = allComplaints.filter(c => {
             const s = (c.status || "").toLowerCase(); return s === "in progress" || s === "pending";
        }).length;
        if(statResolved) statResolved.textContent = allComplaints.filter(c => (c.status || "").toLowerCase() === "resolved").length;
    }

    // ✅ EVENT LISTENERS FOR FILTERS
    searchInput.addEventListener("input", renderTable);
    statusFilter.addEventListener("change", renderTable);

    // ✅ MODAL LOGIC
    function openModal(id) {
        const complaint = allComplaints.find(c => c.id === id);
        if(!complaint) return;
        
        currentComplaintId = id;
        
        let dateStr = "N/A";
        if (complaint.timestamp) {
            const d = complaint.timestamp.toDate ? complaint.timestamp.toDate() : new Date(complaint.timestamp);
            dateStr = d.toLocaleDateString() + " " + d.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
        }

        modalBody.innerHTML = `
            <div class="detail-row">
                <label>Complaint ID</label>
                <p>#${id}</p>
            </div>
            <div class="detail-row">
                <label>Date Submitted</label>
                <p>${dateStr}</p>
            </div>
            <div class="detail-row">
                <label>Contact Phone</label>
                <p>${complaint.phoneNumber || complaint.phone || "N/A"}</p>
            </div>
            <div class="detail-row">
                <label>Train Details</label>
                <p>${complaint.train_number || complaint.trainNumber || "N/A"}</p>
            </div>
            <div class="detail-row">
                <label>Category</label>
                <p>${complaint.category || "N/A"}</p>
            </div>
            <div class="detail-row">
                <label>Description</label>
                <p>${complaint.description || complaint.details || "No description provided."}</p>
            </div>
        `;
        
        // Match status in select dropdown
        const currentStatus = complaint.status || "Registered";
        
        // Loop through options to set exact match
        for (let i = 0; i < updateStatusSelect.options.length; i++) {
            if (updateStatusSelect.options[i].value.toLowerCase() === currentStatus.toLowerCase()) {
                updateStatusSelect.selectedIndex = i;
                break;
            }
        }
        
        modal.classList.remove("hidden");
    }

    closeModalBtn.addEventListener("click", () => {
        modal.classList.add("hidden");
        currentComplaintId = null;
    });

    // Close on outside click
    modal.addEventListener("click", (e) => {
        if(e.target === modal) {
            modal.classList.add("hidden");
            currentComplaintId = null;
        }
    });

    // ✅ UPDATE STATUS
    saveStatusBtn.addEventListener("click", async () => {
        if(!currentComplaintId) return;
        
        const newStatus = updateStatusSelect.value;
        const originalText = saveStatusBtn.innerHTML;
        saveStatusBtn.innerHTML = "Saving...";
        saveStatusBtn.disabled = true;
        
        try {
            const docRef = doc(db, "complaints", currentComplaintId);
            await updateDoc(docRef, {
                status: newStatus,
                updatedAt: new Date()
            });
            
            showToast("Status updated successfully!", "success");
            modal.classList.add("hidden");
        } catch(err) {
            console.error(err);
            showToast("Failed to update status.", "error");
        } finally {
            saveStatusBtn.innerHTML = originalText;
            saveStatusBtn.disabled = false;
        }
    });

    // ✅ TOAST NOTIFICATION
    function showToast(message, type) {
        toast.textContent = message;
        toast.className = `toast toast-${type}`;
        
        // Reflow hack to reset css transition immediately
        void toast.offsetWidth;
        
        setTimeout(() => {
            toast.classList.add("hidden");
        }, 3000);
    }
}