let RichEditor = {};
let isInit = false
let MAX_LEN = 16000;

RichEditor.editor = document.getElementById('editor');

RichEditor.currentSelection = {
    "startContainer": 0,
    "startOffset": 0,
    "endContainer": 0,
    "endOffset": 0
};

RichEditor.isInitFontSize = true;

document.addEventListener("selectionchange", function() {
    if(!isInit&&(document.innerHTML === "undefined" || document.innerHTML === null || document.innerHTML === "")){
        isInit = true
        if (RichEditor.isInitFontSize) {
            document.execCommand("fontSize", false, 2);
        }
        RichEditor.fixFontSize()
    } else {
        RichEditor.backuprange();
    }
});

RichEditor.callback = function() {
    window.location.href = "re-callback://" + encodeURI(RichEditor.getHtml());
}

RichEditor.setReadOnly = function(isReadOnly) {
    if (RichEditor.editor) {
        RichEditor.editor.setAttribute("contenteditable", isReadOnly ? "false" : "true");
    }
}

RichEditor.setInputEnabled = function(inputEnabled) {
    RichEditor.editor.contentEditable = String(inputEnabled);
}

// 获取html文本
RichEditor.getHtml = function() {
    return RichEditor.editor.innerHTML;
}

// 设置html文本
RichEditor.setHtml = function(contents) {
    RichEditor.editor.innerHTML = decodeURIComponent(contents.replace(/\+/g, '%20'));
}

// 获取text
RichEditor.getText = function() {
    return RichEditor.editor.innerText;
}

RichEditor.setBackgroundImage = function(image) {
    RichEditor.editor.style.backgroundImage = image;
}

RichEditor.setBackgroundColor = function(color) {
    document.body.style.backgroundColor = color;
}

RichEditor.undo = function() {
    document.execCommand('undo', false, null);
    let html = RichEditor.editor.innerHTML;
    htmlContentModel.undo(html);
}

RichEditor.redo = function() {
    document.execCommand('redo', false, null);
    let html = RichEditor.editor.innerHTML;
    htmlContentModel.redo(html);
}

RichEditor.setBold = function() {
    document.execCommand('bold', false, null);
}

RichEditor.setItalic = function() {
    document.execCommand('italic', false, null);
}

RichEditor.setUnderline = function() {
    document.execCommand('underline', false, null);
}

RichEditor.setStrikeThrough = function() {
    document.execCommand('strikeThrough', false, null);
}

RichEditor.setTextColor = function(color) {
    RichEditor.restorerange();
    document.execCommand("styleWithCSS", null, true);
    document.execCommand('foreColor', false, color);
    document.execCommand("styleWithCSS", null, false);
}

RichEditor.setFontSize = function(fontSize){
    document.execCommand("fontSize", false, fontSize);
}

RichEditor.setTextBackgroundColor = function(color) {
    RichEditor.restorerange();
    document.execCommand("styleWithCSS", null, true);
    document.execCommand('hiliteColor', false, color);
    document.execCommand("styleWithCSS", null, false);
}

RichEditor.setFontName = function (fontName) {
    document.execCommand('fontName', false, fontName);
}

RichEditor.setJustifyLeft = function() {
    document.execCommand('justifyLeft', false, null);
}

RichEditor.setJustifyRight = function() {
    document.execCommand('justifyRight', false, null);
}

RichEditor.setJustifyCenter = function() {
    document.execCommand('justifyCenter', false, null);
}

RichEditor.tu = function(){
    window.clickp.show();
}

RichEditor.insertHTML = function(html) {
    RichEditor.restorerange();
    document.execCommand('insertHTML', false, html);
}

RichEditor.insertImage = function(url, alt,style) {
    let html = '<img src=" ' + url + ' " alt=" ' + alt + ' " style=" ' + style + ' "/><br/><br/>';
    RichEditor.insertHTML(html);
    RichEditor.editor.scrollIntoView(false)
}


RichEditor.prepareInsert = function() {
    RichEditor.backuprange();
}


RichEditor.setTodo = function(text) {
    let html = '<input type="checkbox" name="'+ text +'" value="'+ text +'"/> &nbsp;';
    document.execCommand('insertHTML', false, html);
}


RichEditor.backuprange = function(){
    let selection = window.getSelection();
    if (selection.rangeCount > 0) {
      let range = selection.getRangeAt(0);
      RichEditor.currentSelection = {
          "startContainer": range.startContainer,
          "startOffset": range.startOffset,
          "endContainer": range.endContainer,
          "endOffset": range.endOffset};
    }
}

RichEditor.enabledEditingItems = function(e) {
    let items = [];
    if (document.queryCommandState('italic')) {
        items.push('italic');
    }
    if (document.queryCommandState('bold')) {
        items.push('bold');
    }
    if (document.queryCommandState('superscript')) {
        items.push('superscript');
    }
    if (document.queryCommandState('subscript')) {
        items.push('subscript');
    }
    if (document.queryCommandState('underline')) {
        items.push('underline');
    }
    if (document.queryCommandState('strikeThrough')) {
        items.push('strikeThrough');
    }
    if (document.queryCommandState('insertUnorderedList')) {
        items.push('unorderedList');
    }
    if (document.queryCommandState('insertOrderedList')) {
        items.push('orderedList');
    }
    if (document.queryCommandState('justifyFull')) {
        items.push('justifyFull');
    }
    if (document.queryCommandState('justifyCenter')) {
        items.push('justifyCenter');
    }
    if (document.queryCommandState('justifyRight')) {
        items.push('justifyRight');
    }
    if (document.queryCommandState('justifyLeft')) {
        items.push('justifyLeft');
    }
    let formatBlock = document.queryCommandValue('formatBlock');
    if (formatBlock.length > 0) {
        items.push(formatBlock);
    }
    if (document.queryCommandState('insertHorizontalRule')) {
        items.push('horizontalRule');
    }
    window.location.href = "re-state://" + encodeURI(items.join(','));
}

RichEditor.restorerange = function() {
    let selection = window.getSelection();
    selection.removeAllRanges();
    let range = document.createRange();
    range.setStart(RichEditor.currentSelection.startContainer, RichEditor.currentSelection.startOffset);
    range.setEnd(RichEditor.currentSelection.endContainer, RichEditor.currentSelection.endOffset);
    selection.addRange(range);
}

RichEditor.blurFocus = function() {
    RichEditor.editor.blur();
}

RichEditor.focus = function() {
    let range = document.createRange();
    range.selectNodeContents(RichEditor.editor);
    range.collapse(false);
    let selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
    RichEditor.editor.focus();
}

RichEditor.removeFormat = function() {
    document.execCommand('removeFormat', false, null);
}

RichEditor.editor.addEventListener("beforeinput", (e) => {
    // 非文本输入直接放行（图片、换行等）
    if (!e.data) {
        return
    }
    // 计算剩余可输入的文案长度
    const remain = MAX_LEN - getPureTextLength(editor)
    // 无剩余可输入，则不让继续输入
    if (remain < 0) {
        e.preventDefault()
        return
    }
    // 判断输入的文案的长度是否超过剩余可输入的长度
    if (e.data.length > remain) {
        e.preventDefault()
        insertTextAtCursor(e.data.slice(0, remain));
        window.location.href = "re-callback://" + encodeURI(RichEditor.getHtml());
        htmlContentModel.htmlContentChange(RichEditor.getHtml());
    }
    // 文案长度如果超过最大长度，则提示
    let editorTextCount = getPureTextLength(editor);
    if (editorTextCount >= MAX_LEN) {
        htmlContentModel.handleTextLength();
    }
});
// Event Listeners
RichEditor.editor.addEventListener("input", RichEditor.callback);
RichEditor.editor.addEventListener("keyup", function(e) {
    let KEY_LEFT = 37, KEY_RIGHT = 39;
    if (e.which === KEY_LEFT || e.which === KEY_RIGHT) {
        RichEditor.enabledEditingItems(e);
    }
});
RichEditor.editor.addEventListener("click", RichEditor.enabledEditingItems);

RichEditor.fixFontSize = function(){
    let font = document.querySelectorAll('font')
    if(!font){
        return
    }
    font.forEach(function(item) {
         if (item.getAttribute('size') === '1') {
             item.style.fontSize='14px';
         }else if (item.getAttribute('size') === '2') {
             item.style.fontSize='16px';
          }else if (item.getAttribute('size') === '3') {
              item.style.fontSize='18px';
         }else if (item.getAttribute('size') === '4') {
              item.style.fontSize='19px';
         } else {
            console.log("fixFontSize null");
         }
        item.removeAttribute("size")
    });
}

RichEditor.removeFormat = function() {
    document.execCommand('removeFormat', false, null);
}

//获取当前光标所在内包含的所有样式
RichEditor.getSelectedNode = function() {
    let node = null;
    let selection = null;
    if (window.getSelection) {
        selection = getSelection();
        node = selection.anchorNode;
    }
    if (node) {
        let item = (node.nodeName === "#text" ? node.parentNode : node);
    }
    if (!node && document.selection) {
        selection = document.selection
        let range = selection.getRangeAt ? selection.getRangeAt(0) : selection.createRange();
        node = range.commonAncestorContainer ? range.commonAncestorContainer :
        range.parentElement ? range.parentElement() : range.item(0);
    }
}

function getPureTextLength(root) {
    return getAllTextNodes(root)
        .reduce((sum, n) => sum + n.nodeValue.length, 0)
}

function getAllTextNodes(root) {
    const nodes = []
    const walker = document.createTreeWalker(
        root,
        NodeFilter.SHOW_TEXT,
        null,
        false
    )

    let node
    while ((node = walker.nextNode())) {
        nodes.push(node)
    }

    return nodes
}

function insertTextAtCursor(text) {
    const sel = window.getSelection()
    if (!sel.rangeCount) {
        return
    }

    const range = sel.getRangeAt(0)
    range.deleteContents()

    const node = document.createTextNode(text)
    range.insertNode(node)

    // 光标移动到插入内容后
    range.setStartAfter(node)
    range.collapse(true)
    sel.removeAllRanges()
    sel.addRange(range)
}

function watchRichText(editor, callback) {
    if (!editor.isContentEditable) {
        console.warn("传入的元素必须设置 contenteditable=true");
    }
    // 1. 内容变化（输入/删除/粘贴）
    editor.addEventListener("input", () => {
        callback({
            type: "content",
            value: editor.innerHTML,
        });
    });
    // 2. 中文输入法兼容
    let composing = false;
    editor.addEventListener("compositionstart", () => (composing = true));
    editor.addEventListener("compositionend", () => {
        composing = false;
        callback({
            type: "content",
            value: editor.innerHTML,
        });
    });
    // 3. 样式/光标变化
    document.addEventListener("selectionchange", () => {
        // 仅在编辑器内触发
        if (!editor.contains(document.activeElement)) {
            return;
        }

        const sel = window.getSelection();
        if (!sel || !sel.rangeCount) {
            return;
        }
        const node = sel.anchorNode ? sel.anchorNode.parentElement : null;

        if (!composing) {
            callback({
                type: "style",
                selectionNode: node,
            });
        }
    });

    // 4. DOM 结构变化（样式标签插入/删除）
    const observer = new MutationObserver((mutations) => {
        callback({
            type: "dom",
            value: editor.innerHTML,
            mutations,
        });
    });

    observer.observe(editor, {
        childList: true,
        characterData: true,
        attributes: true,
        subtree: true,
    });

    // 返回取消监听的方法
    return () => observer.disconnect();
}
// 监听富文本内容发生变化
watchRichText(RichEditor.editor, (change) => {
    switch (change.type) {
        case "content":
            console.log("watchRichText ==> 内容变化:", change.value);
            let html = RichEditor.editor.innerHTML;
            htmlContentModel.htmlContentChange(html);
            break;
        case "style":
            console.log("watchRichText ==> 样式变化，当前节点:", change.selectionNode);
            break;
        case "dom":
            console.log("watchRichText ==> DOM 变化:", change.mutations);
            break;
    }
});




