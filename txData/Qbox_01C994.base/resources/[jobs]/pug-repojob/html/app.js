(() => {
  const LAYOUT_KEY = "pug-repojob:towRemoteLayout:v1";
  const OPACITY_KEY = "pug-repojob:towRemoteOpacity:v1";

  const remoteEl = document.getElementById("remote");
  const titleEl = document.getElementById("remoteTitle");
  const buttonsEl = document.getElementById("remoteButtons");
  const moveBtn = document.getElementById("moveBtn");
  const powerBtn = document.getElementById("powerBtn");
  const opacityBtn = document.getElementById("opacityBtn");
  const centerBtn = document.getElementById("centerBtn");
  const editHint = document.getElementById("editHint");
  const resizeHandle = document.getElementById("resizeHandle");

  let isOpen = false;
  let isEditing = false;
  let options = [];
  let isDimmed = false;

  const clamp = (n, min, max) => Math.max(min, Math.min(max, n));

  const getViewport = () => {
    const w = Math.max(
      document.documentElement?.clientWidth || 0,
      window.innerWidth || 0,
      window.screen?.width || 0
    );
    const h = Math.max(
      document.documentElement?.clientHeight || 0,
      window.innerHeight || 0,
      window.screen?.height || 0
    );
    return { w, h };
  };

  const fetchNui = async (name, data = {}) => {
    const resource = (typeof GetParentResourceName === "function")
      ? GetParentResourceName()
      : "pug-repojob";
    try {
      await fetch(`https://${resource}/${name}`, {
        method: "POST",
        headers: { "Content-Type": "application/json; charset=UTF-8" },
        body: JSON.stringify(data),
      });
    } catch (_) {}
  };

  const iconSvg = (id) => {
    switch (id) {
      case "attach_vehicle":
        return `<svg viewBox="0 0 24 24"><path d="M7 7h6v2H9v6H7V7zm4 10h6V9h-2V7h4v12h-8v-2z"/></svg>`;
      case "unattach_vehicle":
        return `<svg viewBox="0 0 24 24"><path d="M16 8V6H8v2h8zm-8 2h8v8H8v-8zm-2-6h12v2H6V4zm0 16h12v2H6v-2z"/></svg>`;
      case "wind_hitch":
        return `<svg viewBox="0 0 24 24"><path d="M3 12a9 9 0 0115.55-6.36L20 4v6h-6l2.17-2.17A7 7 0 005 12h-2zm18 0a9 9 0 01-15.55 6.36L4 20v-6h6l-2.17 2.17A7 7 0 0019 12h2z"/></svg>`;
      case "unwind_hitch":
        return `<svg viewBox="0 0 24 24"><path d="M12 2a10 10 0 1010 10h-2a8 8 0 11-8-8V2zm1 5h6v2h-6V7zm0 4h6v2h-6v-2z"/></svg>`;
      case "remove_tow_hook":
        return `<svg viewBox="0 0 24 24"><path d="M19 13H5v-2h14v2z"/></svg>`;
      case "put_remote_away":
        return `<svg viewBox="0 0 24 24"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>`;
      default:
        return `<svg viewBox="0 0 24 24"><path d="M12 2l10 10-10 10L2 12 12 2z"/></svg>`;
    }
  };

  const escapeHtml = (s) => String(s)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");

  const setVisible = (show) => {
    if (!show && isOpen) {
      // Save while still visible; hiding would zero out getBoundingClientRect().
      saveLayout();
      setEditing(false, { saveOnExit: false });
    }

    isOpen = show;
    remoteEl.classList.toggle("hidden", !show);
    remoteEl.setAttribute("aria-hidden", show ? "false" : "true");
  };

  const getDefaultLayout = () => {
    const w = 240;
    const h = 740;
    const { w: vw, h: vh } = getViewport();
    const safeW = vw || 1920;
    const safeH = vh || 1080;

    const x = safeW - w - 24;
    const y = Math.max(24, safeH / 2 - h / 2);

    return {
      xPct: clamp(x / safeW, 0, 1),
      yPct: clamp(y / safeH, 0, 1),
      wPct: clamp(w / safeW, 0.1, 0.8),
      hPct: clamp(h / safeH, 0.1, 0.9),
    };
  };

  const persistLayout = (layout) => {
    localStorage.setItem(LAYOUT_KEY, JSON.stringify(layout));
  };

  const loadLayout = () => {
    try {
      const raw = localStorage.getItem(LAYOUT_KEY);
      if (!raw) return getDefaultLayout();
      const parsed = JSON.parse(raw);
      if (!parsed) return getDefaultLayout();
      const { xPct, yPct, wPct, hPct } = parsed;
      if ([xPct, yPct, wPct, hPct].some((v) => typeof v !== "number" || Number.isNaN(v))) {
        return getDefaultLayout();
      }
      return {
        xPct: clamp(xPct, 0, 1),
        yPct: clamp(yPct, 0, 1),
        wPct: clamp(wPct, 0.08, 0.95),
        hPct: clamp(hPct, 0.18, 0.95),
      };
    } catch (_) {
      return getDefaultLayout();
    }
  };

  const resolveLayout = (layout, { center = false } = {}) => {
    const { w: vw, h: vh } = getViewport();
    const safeW = vw || 1920;
    const safeH = vh || 1080;

    const w = clamp(layout.wPct * safeW, 190, Math.max(190, safeW - 20));
    const h = clamp(layout.hPct * safeH, 420, Math.max(420, safeH - 20));
    const minX = 10;
    const minY = 10;
    const maxX = Math.max(minX, safeW - w - 10);
    const maxY = Math.max(minY, safeH - h - 10);
    const x = center
      ? clamp((safeW - w) / 2, minX, maxX)
      : clamp(layout.xPct * safeW, minX, maxX);
    const y = center
      ? clamp((safeH - h) / 2, minY, maxY)
      : clamp(layout.yPct * safeH, minY, maxY);

    return {
      x,
      y,
      w,
      h,
      xPct: clamp(x / safeW, 0, 1),
      yPct: clamp(y / safeH, 0, 1),
      wPct: clamp(w / safeW, 0.08, 0.95),
      hPct: clamp(h / safeH, 0.18, 0.95),
    };
  };

  const applyLayout = (layout) => {
    const resolved = resolveLayout(layout);

    remoteEl.style.left = `${resolved.x}px`;
    remoteEl.style.top = `${resolved.y}px`;
    remoteEl.style.width = `${resolved.w}px`;
    remoteEl.style.height = `${resolved.h}px`;
  };

  const saveLayout = () => {
    const { w: vw, h: vh } = getViewport();
    if (vw < 100 || vh < 100) return;

    const rect = remoteEl.getBoundingClientRect();
    if (!rect || rect.width <= 0 || rect.height <= 0) return;

    const layout = {
      xPct: clamp(rect.left / vw, 0, 1),
      yPct: clamp(rect.top / vh, 0, 1),
      wPct: clamp(rect.width / vw, 0.08, 0.95),
      hPct: clamp(rect.height / vh, 0.18, 0.95),
    };

    persistLayout(layout);
  };

  const loadOpacity = () => {
    try {
      const raw = localStorage.getItem(OPACITY_KEY);
      if (!raw) return false;
      const parsed = JSON.parse(raw);
      return parsed === true;
    } catch (_) {
      return false;
    }
  };

  const saveOpacity = () => {
    localStorage.setItem(OPACITY_KEY, JSON.stringify(isDimmed));
  };

  const applyOpacity = () => {
    remoteEl.classList.toggle("dimmed", isDimmed);
  };

  const renderButtons = () => {
    buttonsEl.innerHTML = "";
    options.forEach((opt) => {
      const btn = document.createElement("button");
      btn.type = "button";
      btn.className = "remote__btn" + (opt.disabled ? " disabled" : "");
      btn.dataset.action = opt.id;
      btn.dataset.netId = (opt.netId ?? "");
      btn.innerHTML = `
        <div class="remote__btnIcon">${iconSvg(opt.id)}</div>
        <div class="remote__btnText">
          <div class="remote__btnLabel">${escapeHtml(opt.label ?? "")}</div>
          <div class="remote__btnDesc">${escapeHtml(opt.description ?? "")}</div>
        </div>
      `;
      btn.addEventListener("click", () => {
        if (isEditing || opt.disabled) return;
        fetchNui("towRemote:action", { action: opt.id, netId: opt.netId ?? null });
      });
      buttonsEl.appendChild(btn);
    });
  };

  const setEditing = (editing, { saveOnExit = true } = {}) => {
    const wasEditing = isEditing;

    isEditing = editing;
    remoteEl.classList.toggle("editing", editing);
    editHint.classList.toggle("hidden", !editing);
    resizeHandle.classList.toggle("hidden", !editing);

    moveBtn.innerHTML = editing
      ? `<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>`
      : `<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 2l3 3h-2v4h-2V5H9l3-3zm0 20l-3-3h2v-4h2v4h2l-3 3zM2 12l3-3v2h4v2H5v2l-3-3zm20 0l-3 3v-2h-4v-2h4V9l3 3z"/></svg>`;

    if (saveOnExit && wasEditing && !editing) saveLayout();
  };

  moveBtn.addEventListener("click", (e) => {
    e.stopPropagation();
    if (!isOpen) return;
    setEditing(!isEditing);
  });

  powerBtn.addEventListener("click", (e) => {
    e.stopPropagation();
    if (!isOpen) return;
    setVisible(false);
    fetchNui("towRemote:close", {});
  });

  opacityBtn.addEventListener("click", (e) => {
    e.stopPropagation();
    if (!isOpen) return;
    isDimmed = !isDimmed;
    applyOpacity();
    saveOpacity();
  });

  centerBtn.addEventListener("click", (e) => {
    e.stopPropagation();
    if (!isOpen) return;

    const centeredLayout = resolveLayout(loadLayout(), { center: true });
    applyLayout(centeredLayout);
    persistLayout(centeredLayout);
  });

  window.addEventListener("keydown", (e) => {
    if (!isOpen) return;
    if (e.key === "Escape") {
      e.preventDefault();
      setVisible(false);
      fetchNui("towRemote:close", {});
    }
  });

  // Drag / resize (edit mode)
  let dragState = null;
  let resizeState = null;

  const isFromControl = (target) =>
    !!target.closest(".mini-btn") ||
    !!target.closest(".fake-btn") ||
    !!target.closest(".remote__btn");

  remoteEl.addEventListener("pointerdown", (e) => {
    if (!isOpen || !isEditing) return;
    if (e.button !== 0) return;
    if (e.target === resizeHandle) return;
    if (isFromControl(e.target)) return;

    const rect = remoteEl.getBoundingClientRect();
    dragState = {
      startX: e.clientX,
      startY: e.clientY,
      startLeft: rect.left,
      startTop: rect.top,
    };
    remoteEl.setPointerCapture(e.pointerId);
  });

  remoteEl.addEventListener("pointermove", (e) => {
    if (!dragState) return;
    const dx = e.clientX - dragState.startX;
    const dy = e.clientY - dragState.startY;

    const newLeft = clamp(dragState.startLeft + dx, 0, window.innerWidth - 60);
    const newTop = clamp(dragState.startTop + dy, 0, window.innerHeight - 60);

    remoteEl.style.left = `${newLeft}px`;
    remoteEl.style.top = `${newTop}px`;
  });

  remoteEl.addEventListener("pointerup", () => {
    if (!dragState) return;
    dragState = null;
    saveLayout();
  });

  resizeHandle.addEventListener("pointerdown", (e) => {
    if (!isOpen || !isEditing) return;
    if (e.button !== 0) return;
    e.stopPropagation();

    const rect = remoteEl.getBoundingClientRect();
    resizeState = {
      startX: e.clientX,
      startY: e.clientY,
      startW: rect.width,
      startH: rect.height,
      left: rect.left,
      top: rect.top,
    };
    resizeHandle.setPointerCapture(e.pointerId);
  });

  resizeHandle.addEventListener("pointermove", (e) => {
    if (!resizeState) return;
    const dx = e.clientX - resizeState.startX;
    const dy = e.clientY - resizeState.startY;

    const maxW = window.innerWidth - resizeState.left - 10;
    const maxH = window.innerHeight - resizeState.top - 10;

    const newW = clamp(resizeState.startW + dx, 190, maxW);
    const newH = clamp(resizeState.startH + dy, 420, maxH);

    remoteEl.style.width = `${newW}px`;
    remoteEl.style.height = `${newH}px`;
  });

  resizeHandle.addEventListener("pointerup", () => {
    if (!resizeState) return;
    resizeState = null;
    saveLayout();
  });

  window.addEventListener("resize", () => {
    if (!isOpen) return;
    applyLayout(loadLayout());
  });

  // NUI messages from Lua
  window.addEventListener("message", (event) => {
    const data = event.data;
    if (!data || data.type !== "towRemote") return;

    if (data.action === "open" || data.action === "update") {
      titleEl.textContent = "Tow";
      options = Array.isArray(data.options) ? data.options : [];

      if (!isOpen) {
        isDimmed = loadOpacity();
        applyOpacity();

        applyLayout(loadLayout());
        setVisible(true);

        requestAnimationFrame(() => {
          if (!isOpen) return;
          applyLayout(loadLayout());
        });
      }

      renderButtons();
      return;
    }

    if (data.action === "close") {
      setVisible(false);
    }
  });

  // Initial hidden
  isDimmed = loadOpacity();
  applyOpacity();
  setVisible(false);
})();
