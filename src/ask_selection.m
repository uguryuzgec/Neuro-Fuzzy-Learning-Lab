function ids = ask_selection(prompt,count,multiple)
while true
    answer=input(prompt,'s');
    [ids,valid]=parse_selection(answer,count,multiple);
    if valid,return;end
    fprintf('Gecersiz secim. 1-%d arasi numara girin; iptal icin 0.\n',count);
end
end
