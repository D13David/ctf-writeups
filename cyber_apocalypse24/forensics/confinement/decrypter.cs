using System.IO;
using System.Security.Cryptography;
using System.Text;

internal class PasswordHasher
{
    public string Hasher(string password)
    {
        string result;
        using (SHA512CryptoServiceProvider provider = new SHA512CryptoServiceProvider())
        {
            byte[] bytes = Encoding.UTF8.GetBytes(password);
            result = Convert.ToBase64String(provider.ComputeHash(bytes));
        }
        return result;
    }
    public string GetHashCode(string password, string salt)
    {
        string password2 = password + salt;
        return this.Hasher(password2);
    }
}

internal class Decrypter
{
    private string _password;

    readonly byte[] salt = new byte[] { 0,1,1,0,1,1,0,0 };

    public Decrypter(string password)
    {
        _password = password;
    }

    public void DecryptFile(string file)
    {
        using FileStream fileStream = new FileStream(file, FileMode.Open, FileAccess.Read);
        byte[] buffer = new byte[fileStream.Length];

        string targetFileName = Path.Combine(Path.GetDirectoryName(file), Path.GetFileNameWithoutExtension(file));

        if (fileStream.Length >= 1000000L)
        {
            fileStream.Read(buffer, 0, buffer.Length);
            buffer[0] ^= 255;
            File.WriteAllBytes(targetFileName, buffer);
            return;
        }

        using Rfc2898DeriveBytes rfc2898DeriveBytes = new Rfc2898DeriveBytes(_password, salt, 4953);
        using (RijndaelManaged rijndaelManaged = new RijndaelManaged())
        {
            rijndaelManaged.Key = rfc2898DeriveBytes.GetBytes(rijndaelManaged.KeySize / 8);
            rijndaelManaged.Mode = CipherMode.CBC;
            rijndaelManaged.Padding = PaddingMode.ISO10126;
            rijndaelManaged.IV = rfc2898DeriveBytes.GetBytes(rijndaelManaged.BlockSize / 8);

            using CryptoStream cryptoStream = new CryptoStream(fileStream, rijndaelManaged.CreateDecryptor(), CryptoStreamMode.Read);
            cryptoStream.Read(buffer, 0, buffer.Length);
            File.WriteAllBytes(targetFileName, buffer);
        }
    }
}

static class Program
{
    static string UserId = "5K7X7E6X7V2D6F"; // from the ransom note
    static string Salt = "0f5264038205edfb1ac05fbb0e8c5e94"; // from disassembled code

    static void Main()
    {
        Queue<string> paths = new Queue<string>();
        PasswordHasher passwordHasher = new PasswordHasher();
        Decrypter decrypter = new Decrypter(passwordHasher.GetHashCode(UserId, Salt));

        paths.Enqueue(@"C:\Users\ctf\Root\Documents");

        while (paths.Count != 0)
        {
            string path = paths.Dequeue();

            foreach (string subDirectory in Directory.GetDirectories(path))
            {
                paths.Enqueue(subDirectory);
            }

            foreach (string file in Directory.GetFiles(path, "*.korp"))
            {
                Console.WriteLine("Decrypting {0}", file);
                decrypter.DecryptFile(file);
            }
        }
    }
}