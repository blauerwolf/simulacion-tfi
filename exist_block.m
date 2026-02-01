function existe = exist_block(bloque)
    try
        get_param(bloque, 'Handle');
        existe = true;
    catch
        existe = false;
    end
end