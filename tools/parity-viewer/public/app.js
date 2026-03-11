(() => {
  let pairs = [];
  let activeIndex = -1;
  let activeFilter = "all";
  let searchQuery = "";

  const elements = {
    list: document.getElementById("snapshot-list"),
    search: document.getElementById("search"),
    stats: document.getElementById("stats"),
    configInfo: document.getElementById("config-info"),
    emptyState: document.getElementById("empty-state"),
    compareView: document.getElementById("compare-view"),
    iosImage: document.getElementById("ios-image"),
    androidImage: document.getElementById("android-image"),
    iosFilename: document.getElementById("ios-filename"),
    androidFilename: document.getElementById("android-filename"),
    iosMissing: document.getElementById("ios-missing"),
    androidMissing: document.getElementById("android-missing"),
  };

  // Load snapshot data
  async function load() {
    try {
      const [snapRes, configRes] = await Promise.all([
        fetch("/api/snapshots"),
        fetch("/api/config"),
      ]);
      const data = await snapRes.json();
      const config = await configRes.json();

      pairs = data.pairs;

      elements.stats.innerHTML = [
        `<strong>${data.pairedCount}</strong> paired`,
        `<strong>${data.iosCount}</strong> iOS`,
        `<strong>${data.androidCount}</strong> Android`,
      ].join(" &middot; ");

      elements.configInfo.innerHTML = [
        "<strong>Snapshot directories:</strong>",
        `iOS: <code>${config.iosDir}</code>`,
        `Android: <code>${config.androidDir}</code>`,
        "",
        "Override with <code>IOS_SNAPSHOTS</code> and <code>ANDROID_SNAPSHOTS</code> env vars.",
      ].join("<br>");

      renderList();

      if (pairs.length === 0) {
        showEmpty();
      }
    } catch (err) {
      elements.stats.textContent = "Failed to load snapshots";
      console.error(err);
    }
  }

  function getFilteredPairs() {
    return pairs.filter((pair) => {
      // Apply text filter
      if (searchQuery) {
        const q = searchQuery.toLowerCase();
        const label = (pair.label || pair.key).toLowerCase();
        if (!label.includes(q) && !pair.key.includes(q)) return false;
      }
      // Apply category filter
      if (activeFilter === "paired") return pair.ios && pair.android;
      if (activeFilter === "ios-only") return pair.ios && !pair.android;
      if (activeFilter === "android-only") return !pair.ios && pair.android;
      return true;
    });
  }

  function renderList() {
    const filtered = getFilteredPairs();

    if (filtered.length === 0) {
      elements.list.innerHTML =
        '<li class="empty-list">No snapshots match your filters.</li>';
      return;
    }

    elements.list.innerHTML = filtered
      .map((pair, i) => {
        const pairType = pair.ios && pair.android
          ? "paired"
          : pair.ios
            ? "ios-only"
            : "android-only";
        const globalIndex = pairs.indexOf(pair);
        const isActive = globalIndex === activeIndex;
        const displayName = pair.label || pair.key;
        // Show just the filename portion
        const shortName = displayName.split("/").pop();

        return `<li class="${isActive ? "active" : ""}" data-index="${globalIndex}">
          <span class="dot ${pairType}"></span>
          <span class="name" title="${displayName}">${shortName}</span>
        </li>`;
      })
      .join("");

    // Attach click handlers
    elements.list.querySelectorAll("li[data-index]").forEach((li) => {
      li.addEventListener("click", () => {
        selectPair(parseInt(li.dataset.index, 10));
      });
    });
  }

  function selectPair(index) {
    if (index < 0 || index >= pairs.length) return;
    activeIndex = index;
    const pair = pairs[index];

    // Update sidebar active state
    elements.list.querySelectorAll("li").forEach((li) => {
      li.classList.toggle(
        "active",
        parseInt(li.dataset.index, 10) === index
      );
    });

    // Show compare view
    elements.emptyState.style.display = "none";
    elements.compareView.style.display = "flex";

    // iOS pane
    if (pair.ios) {
      elements.iosImage.src = pair.ios;
      elements.iosImage.style.display = "block";
      elements.iosMissing.style.display = "none";
      elements.iosFilename.textContent = pair.ios.replace("/snapshots/ios/", "");
    } else {
      elements.iosImage.src = "";
      elements.iosImage.style.display = "none";
      elements.iosMissing.style.display = "block";
      elements.iosFilename.textContent = "—";
    }

    // Android pane
    if (pair.android) {
      elements.androidImage.src = pair.android;
      elements.androidImage.style.display = "block";
      elements.androidMissing.style.display = "none";
      elements.androidFilename.textContent = pair.android.replace(
        "/snapshots/android/",
        ""
      );
    } else {
      elements.androidImage.src = "";
      elements.androidImage.style.display = "none";
      elements.androidMissing.style.display = "block";
      elements.androidFilename.textContent = "—";
    }

    // Scroll selected item into view
    const activeLi = elements.list.querySelector(`li[data-index="${index}"]`);
    if (activeLi) {
      activeLi.scrollIntoView({ block: "nearest" });
    }
  }

  function showEmpty() {
    elements.emptyState.style.display = "block";
    elements.compareView.style.display = "none";
  }

  function navigateList(direction) {
    const filtered = getFilteredPairs();
    if (filtered.length === 0) return;

    if (activeIndex === -1) {
      selectPair(pairs.indexOf(filtered[0]));
      return;
    }

    // Find current position in filtered list
    const currentPair = pairs[activeIndex];
    const currentFilteredIndex = filtered.indexOf(currentPair);
    let nextFilteredIndex = currentFilteredIndex + direction;

    if (nextFilteredIndex < 0) nextFilteredIndex = filtered.length - 1;
    if (nextFilteredIndex >= filtered.length) nextFilteredIndex = 0;

    selectPair(pairs.indexOf(filtered[nextFilteredIndex]));
  }

  // Search input
  elements.search.addEventListener("input", (e) => {
    searchQuery = e.target.value;
    renderList();
  });

  // Filter buttons
  document.querySelectorAll(".filter-btn").forEach((btn) => {
    btn.addEventListener("click", () => {
      document.querySelectorAll(".filter-btn").forEach((b) => b.classList.remove("active"));
      btn.classList.add("active");
      activeFilter = btn.dataset.filter;
      renderList();
    });
  });

  // Keyboard navigation
  document.addEventListener("keydown", (e) => {
    // Don't capture when typing in search
    if (document.activeElement === elements.search) {
      if (e.key === "Escape") {
        elements.search.blur();
        e.preventDefault();
      }
      if (e.key === "ArrowDown" || e.key === "ArrowUp") {
        elements.search.blur();
      }
      return;
    }

    switch (e.key) {
      case "ArrowDown":
      case "j":
        e.preventDefault();
        navigateList(1);
        break;
      case "ArrowUp":
      case "k":
        e.preventDefault();
        navigateList(-1);
        break;
      case "/":
        e.preventDefault();
        elements.search.focus();
        break;
    }
  });

  load();
})();
